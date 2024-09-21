import ComposableArchitecture
import SwiftUI

struct ImportView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    VStack(spacing: 20) {
      FileListView(store: store, importing: true)
      Spacer()
      CommandPreviewView(store: store, importing: true)
    }
    .background {
      ShortcutsView(store: store)
    }
    .toolbar {
      toolbar()
    }
  }

  @ToolbarContentBuilder
  private func toolbar() -> some ToolbarContent {
    ToolbarItem(placement: .destructiveAction) {
      Button("Cancel(ESC)", role: .cancel) {
        store.send(.onCancelImportButtonTapped)
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
