import ComposableArchitecture
import SwiftUI

struct WebIndicatorView: View {
  let url: URL
  var wkRefreshCount: Int
  @State var infoPopOver = false

  var body: some View {
    HStack(spacing: 4) {
      Text(url.lastPathComponent)
      HStack {
        Button(action: { infoPopOver.toggle() }) {
          Image(systemName: "info.circle")
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $infoPopOver) {
          HStack(spacing: 4) {
            let abs = url.path(percentEncoded: false)
            Text(abs)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
            CopyButton{
              abs
            }
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
        }
      }
    }
    .modifier(RippleEffect(at: .zero, trigger: wkRefreshCount))
  }
}
