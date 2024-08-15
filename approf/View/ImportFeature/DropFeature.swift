import ComposableArchitecture
import Foundation

@Reducer
struct DropFeature {
  @Reducer(state: .equatable)
  enum Destination {
    case uth(UnderTheHood)
  }

  @ObservableState
  struct State: Equatable {
    var dropping = false
    @Presents var destination: Destination.State?
  }

  enum Action {
    case destination(PresentationAction<Destination.Action>)
    case onCursorEnter
    case onCursorLeave
    case onDropEnds([URL])

    case delegate(Delegate)

    @CasePathable
    enum Delegate {
      case addNewBasic(PProfBasic)
      case addNewBasics([PProfBasic])
      case selectPProf(UUID)
    }
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.uuid) var uuid
  @Dependency(\.date) var date

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .onCursorEnter:
        state.dropping = true
        return .none
      case .onCursorLeave:
        state.dropping = false
        return .none
      case let .onDropEnds(urls):
        let filePaths = urls.map { $0.path(percentEncoded: false) }
        if filePaths.isEmpty {
          return .none
        } else if filePaths.count == 1 {
          let basic = PProfBasic(uuid: uuid(), filePaths: filePaths, createdAt: date.now, presentation: .dft)
          return .send(.delegate(.addNewBasic(basic)))
        } else if filePaths.count == 2 {
          state.destination = .uth(UnderTheHood.State(basic: Shared(PProfBasic(uuid: uuid(), filePaths: filePaths, createdAt: date.now, presentation: .diff))))
          return .none
        } else {
          state.destination = .uth(UnderTheHood.State(basic: Shared(PProfBasic(uuid: uuid(), filePaths: filePaths, createdAt: date.now, presentation: .acc))))
          return .none
        }
      case .destination(.presented(.uth(.delegate(.onConfirmImportButtonTapped)))):
        guard case let .uth(uthFeature) = state.destination else {
          return .none
        }
        state.destination = nil
        // When DropView disappears, the animation for the profs list doesn't work.
        // To fix this, update the profs list after DropView has fully disappeared.
        if case .dft = uthFeature.basic.presentation {
          let basics = uthFeature.basic.filePaths.reversed().map {
            PProfBasic(uuid: uuid(), filePaths: [$0], createdAt: date.now, presentation: .dft)
          }
          return .run { send in
            try await clock.sleep(for: .seconds(0.25))
            await send(.delegate(.addNewBasics(basics)))
          }
        } else {
          let basic = PProfBasic(uuid: uuid(), filePaths: uthFeature.basic.filePaths, createdAt: date.now, presentation: uthFeature.basic.presentation)
          return .run { send in
            try await clock.sleep(for: .seconds(0.25))
            await send(.delegate(.addNewBasic(basic)))
          }
        }
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
