import ComposableArchitecture
import SwiftUI

struct DetailView: View {
  @Bindable var store: StoreOf<DetailFeature>

  var body: some View {
    VStack {
      if store.subViewType == .graphic, let s = store.scope(state: \.period.success, action: \.period.success) {
        SuccessView(store: s)
      } else {
        UnderTheHoodView(store: store.scope(state: \.uth, action: \.uth), periodStatus: store.periodStatus)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding(.horizontal, 8)
    .padding(.bottom, 8)
    .onAppear {
      store.send(.onAppear)
    }
    .toolbar {
      if case .success = store.period {
        ToolbarItem(placement: .navigation) {
          Button(action: {
            store.send(.onSwitchViewButtonTapped, animation: .default)
          }) {
            Image(systemName: store.subViewType.systemImage)
          }
          .help(store.subViewType.help)
        }
      }
    }
    .animation(.default, value: store.period)
  }
}

struct StatusView: View {
  var body: some View {
    HStack(spacing: 1) {
      Image(systemName: "smallcircle.filled.circle")
        .symbolRenderingMode(.palette)
        .foregroundStyle(.green, .clear)
        .scaleEffect(2)
        .symbolEffect(.pulse, options: .speed(0.5))
      Text("Running")
        .foregroundStyle(.secondary)
    }
    .font(.caption)
    .padding(.horizontal, 3)
    .padding(.vertical, 1)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 7))
    .padding(.trailing, 4)
    .padding(.bottom, 2)
  }
}
