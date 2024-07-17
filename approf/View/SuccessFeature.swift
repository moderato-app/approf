import ComposableArchitecture
import Foundation
import WebKit

@Reducer
struct SuccessFeature {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    let process: Process
    let port: UInt16
    let wk: WKWebView
    var fullyLoaded = false

  }

  enum Action {
    case stop
    case onFullyLoaded
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
      case onTermimated
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .onFullyLoaded:
        state.fullyLoaded = true
        return .none
      case .stop:
        if state.process.isRunning {
          state.process.terminate()
        }
        return .send(.delegate(.onTermimated))
      }
    }
  }
}
