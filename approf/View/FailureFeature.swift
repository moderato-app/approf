import ComposableArchitecture
import Foundation

extension FailureFeature {
  enum Cause: Equatable {
    case file(String)
    case process(String)
    case httpDetect(String)
    case pipeDetect(String)
  }
}

@Reducer
struct FailureFeature {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    let cause: Cause
  }

  enum Action {
    case launchButtonTapped
    case delegate(Delegate)

    @CasePathable
    enum Delegate {
      case launchButtonTapped
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        .none
      case .launchButtonTapped:
        .send(.delegate(.launchButtonTapped))
      }
    }
  }
}
