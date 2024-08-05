// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct NameView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  var importing: Bool = false

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      Text("Name")
        .foregroundStyle(.secondary)
      TextField(store.basic.computedName, text: $store.basic.name.sending(\.onNameChanged))
        .textFieldStyle(.plain)
        .background(.clear)
        .padding(.leading, 8)
        .padding(.vertical, 3)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(.bar)
            .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
        )
    }
  }
}
