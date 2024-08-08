import ComposableArchitecture
import SwiftUI

struct NavigaionView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationSplitView {
      list().navigationSplitViewColumnWidth(min: 200, ideal: 300)
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
    List(selection: $store.pprofsSelectedId.sending(\.onPprofsSelectedIdChanged).animation()) {
      ForEach(store.scope(state: \.pprofs, action: \.pprofs), id: \.basic.id) { pprofStore in
        PProfRowView(store: pprofStore)
          .addHiddenView(pprofStore.id) {
            if store.pprofsSelectedId == pprofStore.id {
              rowContextMenu(pprofUUID: pprofStore.id)
            }
          }
          .contextMenu { rowContextMenu(pprofUUID: pprofStore.id) }
          .listRowSeparator(.visible)
          .listRowSeparatorTint(.secondary.opacity(0.5))
      }
      .onMove { from, to in
        store.send(.onMove(from: from, to: to), animation: .default)
      }
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
      store.send(.onMoveUpCommand, animation: .default)
    }) {
      Text("Move Up")
    }
    .keyboardShortcut(.upArrow, modifiers: [.option, .command])
    Button(action: {
      store.send(.onMoveDownCommand, animation: .default)
    }) {
      Text("Move Down")
    }
    .keyboardShortcut(.downArrow, modifiers: [.option, .command])
    Button(action: {
      store.send(.deleteButtonTapped(pprofUUID))
    }) {
      Text("Delete").foregroundStyle(.red)
    }
    .keyboardShortcut(.delete, modifiers: [.shift, .command])
  }
}
