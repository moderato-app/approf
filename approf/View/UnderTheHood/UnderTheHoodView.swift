import ComposableArchitecture
import PopupView
import SwiftUI

struct UnderTheHoodView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  let periodStatus: PeroidStatus

  var body: some View {
    VStack(spacing: 20) {
      NameView(store: store)
      FileListView(store: store, importing: false)
      CommandPreviewView(store: store, importing: false)
      Spacer().frame(height: 10)
      TerminalView(store: store)
      ActionButtonView(store: store, periodStatus: periodStatus)
      Spacer()
    }
    .background {
      ShortcutsView(store: store)
    }
    .popup(item: $store.scope(state: \.destination?.notification, action: \.destination.notification), itemView: { notiStore in
      NotificationView(store: notiStore)
    }) {
      $0.type(.floater())
        .position(.bottomTrailing)
        .animation(.spring())
    }
  }
}
