import AppKit
import ComposableArchitecture
import SwiftUI

struct NavigaionView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationSplitView {
      List(store.scope(state: \.pprofs, action: \.pprofs),
           selection: $store.pprofsSelectedId.sending(\.onPprofsSelectedIdChanged))
      { pprofStore in
        PProfRowView(store: pprofStore)
          .contextMenu {
            Button(action: {
              store.send(.deleteButtonTapped(pprofStore.id))
            }) {
              Text("Delete").foregroundStyle(.red)
                + Text("    ⌘⇧+⌫").foregroundStyle(.secondary)
            }
          }
          .tag(pprofStore.basic.id)
          .listRowSeparator(.visible)
          .listRowSeparatorTint(.secondary.opacity(0.5))
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 300)
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
