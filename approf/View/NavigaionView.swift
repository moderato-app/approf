import ComposableArchitecture
import SwiftUI

struct NavigaionView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationSplitView {
      list().background { shortcuts() }
        .navigationSplitViewColumnWidth(min: 200, ideal: 300)
    } detail: {
      detail()
    }
    .navigationTitle("")
    .onAppear {
      store.send(.onAppear)
    }
  }

  @ViewBuilder
  private func list() -> some View {
    List(store.scope(state: \.pprofs, action: \.pprofs),
         selection: $store.pprofsSelectedId.sending(\.onPprofsSelectedIdChanged).animation())
    { pprofStore in
      PProfRowView(store: pprofStore)
        .contextMenu { rowContextMenu(pprofUUID: pprofStore.id) }
        .tag(pprofStore.basic.id)
        .listRowSeparator(.visible)
        .listRowSeparatorTint(.secondary.opacity(0.5))
    }
  }

  @ViewBuilder
  private func detail() -> some View {
    if let selectedId = store.pprofsSelectedId, let st = store.scope(state: \.pprofs[id: selectedId], action: \.pprofs[id: selectedId]) {
      DetailView(store: st).id(st.id)
        .sc("w", modifiers: [.command]) {
          store.send(.onCloseTabCommand)
        }
    } else {
      WelcomeView()
    }
  }

  @ViewBuilder
  private func rowContextMenu(pprofUUID: UUID) -> some View {
    Button(action: {
      store.send(.deleteButtonTapped(pprofUUID))
    }) {
      Text("Delete").foregroundStyle(.red)
    }
    .keyboardShortcut(.delete, modifiers: [.command, .shift])
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
