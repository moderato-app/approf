import SwiftUI

struct ScrollableTextBox<Content>: View where Content: View {
  var heightLimit: CGFloat? = nil
  @ViewBuilder
  var content: () -> Content
  @State var contentHeight: CGFloat = 10

  var body: some View {
    Group {
      if let limit = heightLimit {
        ScrollView {
          HStack {
            VStack(alignment: .leading) {
              content()
            }
            Spacer()
          }
          .textSelection(.enabled)
          .onGeometryChange(for: CGFloat.self) { proxy in proxy.size.height } action: { contentHeight = $0 }
        }
        .frame(height: min(contentHeight, limit))
      } else {
        ScrollView {
          HStack {
            VStack(alignment: .leading) {
              content()
            }
            Spacer()
          }
          .textSelection(.enabled)
        }
      }
    }
    .padding(8)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.bar)
        .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
    )
  }
}
