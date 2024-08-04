import ComposableArchitecture
import SwiftUI

struct ImportView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    VStack(spacing: 20) {
      FileListView(store: store)
      CommandPreviewView(store: store)
      Spacer()
    }
    .background {
      ShortcutsView(store: store)
    }
    .toolbar {
      toolbar()
    }
    .onDisappear {
      store.send(.delegate(.onImportViewAutoDismissed))
    }
  }
  
  @ToolbarContentBuilder
  private func toolbar() -> some ToolbarContent {
    ToolbarItem(placement: .destructiveAction) {
      Button("Cancel(ESC)", role: .cancel) {
        store.send(.delegate(.onCancelImportButtonTapped))
      }
    }
    ToolbarItem(placement: .confirmationAction) {
      Button("Done⏎") {
        store.send(.delegate(.onConfirmImportButtonTapped))
      }
      .keyboardShortcut(.return, modifiers: [])
    }
  }
}

struct ImportViewV2App: App {
  var body: some Scene {
    WindowGroup {
      ImportViewV2(store: UnderTheHood.mock)
    }
  }
}
