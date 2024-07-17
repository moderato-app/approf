import ComposableArchitecture
import Foundation

@Reducer
struct UnderTheHood {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    var selection: String?
  }

  enum Action {
    case onSelectionChanged(String?)
    case onPresentationChanged(PProfPresentation)
    case onSelectFilesEnd([String])

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
      case onCancelImportButtonTapped
      case onConfirmImportButtonTapped

      case launchButtonTapped
      case stopButtonTapped
    }
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case let .onPresentationChanged(p):
        changePresentation(&state, p)
        return .none
      case let .onSelectionChanged(filePath):
        state.selection = filePath
        return .none
      case let .onSelectFilesEnd(filePaths):
        addFiles(&state, filePaths: filePaths)
        return .none
      case let .onMove(from, to):
        move(&state, from, to)
        return .none
      case .onDeleteCommand:
        if let selection = state.selection {
          delete(&state, selection)
        }
        return .none
      case let .onDeleteMenuTapped(filePath):
        delete(&state, filePath)
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
        changePresentation(&state, state.basic.presentation.next)
        return .none
      case .onPrevPresentationCommand:
        state.basic.presentation = state.basic.presentation.prev
        return .none
      }
    }
  }

  private func changePresentation(_ state: inout Self.State, _ presentation: PProfPresentation) {
    if state.basic.filePaths.count <= 1 {
      state.basic.presentation = .dft
    } else {
      state.basic.presentation = presentation
    }
  }

  private func move(_ state: inout Self.State, _ source: IndexSet, _ destination: Int) {
    state.basic.filePaths.move(fromOffsets: source, toOffset: destination)
  }

  private func addFiles(_ state: inout Self.State, filePaths: [String]) {
    for fp in filePaths {
      if !state.basic.filePaths.contains(fp) {
        state.basic.filePaths.append(fp)
      }
    }
  }

  /// Remove an element and update the selection accordingly
  private func delete(_ state: inout Self.State, _ filePath: String) {
    // Remember the selection index before deleting an element
    var originalIndex: Int?
    if let selection = state.selection {
      originalIndex = state.basic.filePaths.firstIndex(of: selection)
    }

    if state.basic.filePaths.count > 1 {
      state.basic.filePaths.removeAll { $0 == filePath }
      if state.basic.filePaths.count == 1 {
        state.basic.presentation = .dft
      }
    }

    if let selection = state.selection {
      // If the selected element is deleted
      if !state.basic.filePaths.contains(where: { $0 == selection }), let originalIndex = originalIndex {
        if originalIndex < state.basic.filePaths.count {
          // If there were elements after it, select the next one
          state.selection = state.basic.filePaths[originalIndex]
        } else {
          // Otherwise(selection was the last element), select the last element in the list
          state.selection = state.basic.filePaths.last
        }
      }
    }
  }

  private func moveUp(_ state: inout Self.State, _ filePath: String) {
    guard let index = state.basic.filePaths.firstIndex(where: { $0 == filePath }) else {
      return
    }
    if index - 1 >= 0 {
      state.basic.filePaths.move(fromOffsets: IndexSet([index]), toOffset: index - 1)
    }
  }

  private func moveDown(_ state: inout Self.State, _ filePath: String) {
    guard let index = state.basic.filePaths.firstIndex(where: { $0 == filePath }) else {
      return
    }
    if index + 2 <= state.basic.filePaths.count {
      state.basic.filePaths.move(fromOffsets: IndexSet([index]), toOffset: index + 2)
    }
  }
}