import Combine
import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct DropAndAppendView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  @State var dropping = false

  var body: some View {
    Rectangle()
      .fill(.clear)
      .allowsHitTesting(false)
      .onDrop(of: allowedImportFileTypes, delegate: DropFileDelegate(dropping: $dropping) { urls in
        store.send(.onAddURLs(urls))
      })
  }
}
