import ComposableArchitecture
import Foundation

@Reducer
struct DropAndAppendFeature {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
  }

  enum Action {
    case onDropEnds([URL])
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .onDropEnds(urls):
        let u = urls.map { $0.path(percentEncoded: false) }
        state.basic.filePaths.append(contentsOf: u)
        return .none
      }
    }
  }
}
