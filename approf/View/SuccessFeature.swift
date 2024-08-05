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

    // this is a copy of basic, and is used detect if changes have been made before process is terminated
    let snapshot: PProfBasic

    init(basic: Shared<PProfBasic>, process: Process, port: UInt16, wk: WKWebView) {
      _basic = basic
      self.process = process
      self.port = port
      self.wk = wk
      self.snapshot = basic.wrappedValue
    }
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
