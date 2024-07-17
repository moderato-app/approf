import ComposableArchitecture
import Foundation

@Reducer
struct IdleFeature {
  @ObservableState
  struct State: Equatable {}

  enum Action {
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
      case launchButtonTapped
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .delegate:
        .none
      }
    }
  }
}
