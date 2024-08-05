import ComposableArchitecture
import Foundation

@Reducer
struct NameFeature {

  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    var editMode: Bool = false
  }

  enum Action {
    case onNameChanged(String)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .onNameChanged(name):
        state.basic.name = name
        return .none
      }
    }
  }
}
