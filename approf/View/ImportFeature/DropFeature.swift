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
      case selectPProf(UUID)
    }
  }

  @Dependency(\.continuousClock) var clock

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
          let basic = PProfBasic(filePaths: filePaths, presentation: .dft)
          return .run { send in
            try await clock.sleep(for: .seconds(0.1))
            await send(.delegate(.addNewBasic(basic)), animation: .default)
            try await clock.sleep(for: .seconds(0.1))
            await send(.delegate(.selectPProf(basic.id)), animation: .default)
          }
        } else if filePaths.count == 2 {
          state.destination = .uth(UnderTheHood.State(basic: Shared(PProfBasic(filePaths: filePaths, presentation: .diff))))
          return .none
        } else {
          state.destination = .uth(UnderTheHood.State(basic: Shared(PProfBasic(filePaths: filePaths, presentation: .acc))))
          return .none
        }
      case .destination(.presented(.uth(.delegate(.onCancelImportButtonTapped)))), .destination(.presented(.uth(.delegate(.onImportViewAutoDismissed)))):
        state.destination = nil
        return .none
      case .destination(.presented(.uth(.delegate(.onConfirmImportButtonTapped)))):
        guard case let .uth(uthFeature) = state.destination else {
          return .none
        }
        state.destination = nil
        if case .dft = uthFeature.basic.presentation {
          let filePaths = uthFeature.basic.filePaths
          return .run { send in
            for fp in filePaths.reversed() {
              try await clock.sleep(for: .seconds(0.03))
              let basic = PProfBasic(filePaths: [fp], presentation: .dft)
              await send(.delegate(.addNewBasic(basic)), animation: .default)
              if fp == filePaths.first {
                try await clock.sleep(for: .seconds(0.03))
                await send(.delegate(.selectPProf(basic.id)), animation: .default)
              }
            }
          }
        } else {
          let basic = PProfBasic(filePaths: uthFeature.basic.filePaths, presentation: uthFeature.basic.presentation)
          return .run { send in
            try await clock.sleep(for: .seconds(0.03))
            await send(.delegate(.addNewBasic(basic)), animation: .default)
            try await clock.sleep(for: .seconds(0.03))
            await send(.delegate(.selectPProf(basic.id)), animation: .default)
          }
        }
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
