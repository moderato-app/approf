// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct PresPickerView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    VStack(spacing: 2) {
      Text(store.basic.presentation.explanation)
        .font(.footnote)
        .fontDesign(.default)
        .foregroundStyle(.secondary)
        .animation(.easeInOut(duration: 0.1), value: store.basic.presentation)
      Picker("", selection: $store.basic.presentation.sending(\.onPresentationChanged)) {
        ForEach(PProfPresentation.allCases, id: \.self) { c in
          Text("\(c.rawValue)")
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .containerRelativeFrame(.horizontal) { v, _ in v * 0.5 }
    }
  }
}
