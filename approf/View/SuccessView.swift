import ComposableArchitecture
import KeyboardShortcuts
import SwiftUI

struct SuccessView: View {
  @Bindable var store: StoreOf<SuccessFeature>
  @State var invert = false
  @ObservedObject var asm = AppStorageManager.shared
  @Environment(\.openURL) var openURL
  @State var addrBarWidth: CGFloat = 300
  @State var wkState = WKState()

  var body: some View {
    VStack {
      WkWrapper(wk: store.wk, wkState: wkState)
        .if(!asm.lightsOn) {
          $0.colorInvert()
        }
    }
    // Before 'wk' is fully loaded, it shows a background color. colorInvert turns this background color into a blinding foreground color.
    // Adding a short delay to prevent a color flash. This only occurs the first time 'wk' displays.
    .opacity(store.fullyLoaded ? 1 : 0)
    .toolbar {
      ToolbarItem(placement: .navigation) {
        LightsOnButton(lightsOn: $asm.lightsOn)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .help("Toggle Lights\nJust a simple color inversion in the app window, no CSS involved.")
          .opacity(store.fullyLoaded ? 1 : 0)
      }

      ToolbarItem(placement: .status) {
        statusBar()
          .frame(width: addrBarWidth)
          .opacity(store.fullyLoaded ? 1 : 0)
      }

      ToolbarItem(placement: .automatic) {
        Button(action: { store.send(.stop) }) {
          Image(systemName: "square")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .help("Stop\nTerminate the pprof process.")
        .opacity(store.fullyLoaded ? 1 : 0)
      }
    }
    .onGeometryChange(for: CGFloat.self) { proxy in
      proxy.size.width / 2
    } action: {
      self.addrBarWidth = $0
    }
  }

  @State var wkRefreshCount = 0
  @ViewBuilder
  func statusBar() -> some View {
    HStack(alignment: .firstTextBaseline) {
      Button(action: {
        if let url = wkState.url {
          openURL(url)
        }
      }) {
        Image(systemName: "safari")
      }
      .buttonStyle(.borderless)
      .help("Open in Browser")

      Spacer()

      if let url = wkState.url {
        Text(url.absoluteString)
          .lineLimit(1)
          .foregroundStyle(.foreground.opacity(0.8))
          .modifier(RippleEffect(at: .zero, trigger: wkRefreshCount))
        ProgressView()
          .scaleEffect(0.4)
          .frame(width: 5, height: 5)
          .opacity(wkState.loading ? 1 : 0)
      }

      Spacer()

      Button(action: {
        wkRefreshCount += 1
        store.wk.reload()
      }) {
        Image(systemName: "arrow.clockwise")
      }
      .buttonStyle(.borderless)
      .keyboardShortcut("r", modifiers: [.command])
      .help("Refresh")
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
    )
  }
}
