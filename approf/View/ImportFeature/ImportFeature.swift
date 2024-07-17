import ComposableArchitecture
import Foundation

@Reducer
struct ImportFeature {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    var selection: String?
  }

  enum Action {
    case onSelectionChanged(String?)
    case onpresentationChanged(PProfPresentation)

    case onMove(from: IndexSet, to: Int)
    case onDeleteCommand
    case onDeleteMenuTapped(String)
    case onMoveUpCommand
    case onMoveDownCommand
    case onNextPresentationCommand
    case onPrevPresentationCommand

    case delegate(Delegate)
    @CasePathable
    enum Delegate {
      case onImportViewAutoDismissed
      case onCancelImportButtonTapped
      case onConfirmImportButtonTapped
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case let .onpresentationChanged(p):
        state.basic.presentation = p
        return .none
      case let .onSelectionChanged(filePath):
        state.selection = filePath
        return .none
      case let .onMove(from, to):
        move(&state, from, to)
        return .none
      case .onDeleteCommand:
        if let selection = state.selection {
          delete(&state, selection)
        }
        return .none
      case let .onDeleteMenuTapped(url):
        delete(&state, url)
        return .none
      case .onMoveUpCommand:
        if let selection = state.selection {
          moveUp(&state, selection)
        }
        return .none
      case .onMoveDownCommand:
        if let selection = state.selection {
          moveDown(&state, selection)
        }
        return .none
      case .onNextPresentationCommand:
        state.basic.presentation = state.basic.presentation.next
        return .none
      case .onPrevPresentationCommand:
        state.basic.presentation = state.basic.presentation.prev
        return .none
      }
    }
  }

  private func move(_ state: inout Self.State, _ source: IndexSet, _ destination: Int) {
    state.basic.filePaths.move(fromOffsets: source, toOffset: destination)
  }

  private func delete(_ state: inout Self.State, _ filePath: String) {
    state.basic.filePaths.removeAll { $0 == filePath }
  }

  private func moveUp(_ state: inout Self.State, _ filePath: String) {
    guard let index = state.basic.filePaths.firstIndex(where: { $0 == filePath }) else {
      return
    }
    if index - 1 >= 0 {
      if #available(macOS 15.0, *) {
        state.basic.filePaths.moveSubranges(RangeSet([index]), to: index - 1)
      } else {
        state.basic.filePaths.move(fromOffsets: IndexSet([index]), toOffset: index - 1)
      }
    }
  }

  private func moveDown(_ state: inout Self.State, _ filePath: String) {
    guard let index = state.basic.filePaths.firstIndex(where: { $0 == filePath }) else {
      return
    }
    if index + 2 <= state.basic.filePaths.count {
      if #available(macOS 15.0, *) {
        state.basic.filePaths.moveSubranges(RangeSet([index]), to: index + 2)
      } else {
        state.basic.filePaths.move(fromOffsets: IndexSet([index]), toOffset: index + 2)
      }
    }
  }
}
