import AppKit
import ComposableArchitecture
import KeyboardShortcuts
import SwiftUI

struct NavigaionView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationSplitView {
      List(store.scope(state: \.pprofs, action: \.pprofs),
           selection: $store.pprofsSelectedId.sending(\.onPprofsSelectedIdChanged))
      { pprofStore in
        PProfRowView(
          store: pprofStore,
          running: pprofStore.isRunning
        )
        .contextMenu {
          Button("Delete", systemImage: "trash", role: .destructive) {
            store.send(.deleteButtonTapped(pprofStore.id))
          }
        }
        .tag(pprofStore.basic.id)
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 300)
      .scrollContentBackground(.hidden)
      .overlay {
        shortcuts()
      }
    } detail: {
      if let selectedId = store.pprofsSelectedId, let st = store.scope(state: \.pprofs[id: selectedId], action: \.pprofs[id: selectedId]) {
        DetailView(store: st).id(st.id)
          .sc("w", modifiers: [.command]) {
            store.send(.onCloseTabCommand)
          }
      } else {
        WelcomeView()
      }
    }
    .navigationTitle("")
    .animation(.easeInOut(duration: 0.2), value: store.pprofsSelectedId)
    .onAppear {
      store.send(.onAppear)
    }
  }

  @ViewBuilder
  private func shortcuts() -> some View {
    Rectangle()
      .fill(.clear)
      .frame(width: 1, height: 1)
      .allowsHitTesting(false)
      .sc(.delete, modifiers: [.command, .shift]) {
        store.send(.onDeleteCommand)
      }
  }
}
