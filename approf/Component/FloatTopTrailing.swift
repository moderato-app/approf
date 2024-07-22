import ComposableArchitecture
import SwiftUI

struct NotificationView: View {
  @Bindable var store: StoreOf<NotificationFeature>

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(.background)

      HStack(spacing: 7) {
        Circle()
          .foregroundStyle(.orange)
          .frame(width: 10, height: 10)

        VStack(alignment: .leading, spacing: 2) {
          Text(store.text)
            .fontWeight(.bold)
          HStack {
            Text("\(Date().formatted(date: .omitted, time: .shortened))")
              .foregroundStyle(.secondary)
              .padding(.trailing, 8)
            Spacer()
            if let seconds = store.seconds {
              Text("Disappears in \(seconds) seconds")
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
          }
        }
      }
      .padding(8)
    }
    .fixedSize()
    .onAppear {
      store.send(.onAppear)
    }
  }
}
