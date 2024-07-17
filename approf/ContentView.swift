import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  @Bindable var store: StoreOf<AppFeature>
  @State var uiState = UIState.shared

  var body: some View {
    NavigaionView(store: store)
      .onHover { uiState.mouseInsideWindow = $0 }
      .overlay {
        DropView(store: store.scope(state: \.drop, action: \.drop))
      }
  }
}
