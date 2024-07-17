import ComposableArchitecture
import Foundation

@Reducer
struct DropFeature: Equatable {
  @Reducer(state: .equatable)
  enum Destination {
    case importing(ImportFeature)
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
            try await Task.sleep(for: .seconds(0.1))
            await send(.delegate(.addNewBasic(basic)), animation: .default)
            try await Task.sleep(for: .seconds(0.1))
            await send(.delegate(.selectPProf(basic.id)), animation: .default)
          }
        } else if filePaths.count == 2 {
          state.destination = .importing(ImportFeature.State(basic: Shared(PProfBasic(filePaths: filePaths, presentation: .diff))))
          return .none
        } else {
          state.destination = .importing(ImportFeature.State(basic: Shared(PProfBasic(filePaths: filePaths, presentation: .acc))))
          return .none
        }
      case .destination(.presented(.importing(.delegate(.onCancelImportButtonTapped)))), .destination(.presented(.importing(.delegate(.onImportViewAutoDismissed)))):
        state.destination = nil
        return .none
      case .destination(.presented(.importing(.delegate(.onConfirmImportButtonTapped)))):
        guard case let .importing(importingFeature) = state.destination else {
          return .none
        }
        state.destination = nil
        if case .dft = importingFeature.basic.presentation {
          let filePaths = importingFeature.basic.filePaths
          return .run { send in
            for fp in filePaths.reversed() {
              try await Task.sleep(for: .seconds(0.03))
              let basic = PProfBasic(filePaths: [fp], presentation: .dft)
              await send(.delegate(.addNewBasic(basic)), animation: .default)
              if fp == filePaths.first {
                try await Task.sleep(for: .seconds(0.03))
                await send(.delegate(.selectPProf(basic.id)), animation: .default)
              }
            }
          }
        } else {
          let basic = PProfBasic(filePaths: importingFeature.basic.filePaths, presentation: importingFeature.basic.presentation)
          return .run { send in
            try await Task.sleep(for: .seconds(0.03))
            await send(.delegate(.addNewBasic(basic)), animation: .default)
            try await Task.sleep(for: .seconds(0.03))
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
