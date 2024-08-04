import ComposableArchitecture
import SwiftUI

struct ImportView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    VStack(spacing: 20) {
      FileListView(store: store, importing: true)
        .containerRelativeFrame(.vertical) { y, _ in y * 0.6 }
      Spacer()
      CommandPreviewView(store: store, importing: true)
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
      ImportView(store: UnderTheHood.mock)
    }
  }
}
