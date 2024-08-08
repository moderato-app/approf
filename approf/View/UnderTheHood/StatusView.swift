import SwiftUI
import ComposableArchitecture

struct UTHStatusView: View {
  @Bindable var store: StoreOf<DetailFeature>

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      switch store.period {
      case .idle:
        EmptyView()
      case .terminated:
        Image(systemName: "moon.zzz")
        Text("Terminated")
      case .launching:
        RotatingSF("arrow.clockwise")
          .foregroundStyle(.orange)
        Text("Launching")
          .foregroundStyle(.orange)
        EmptyView()
      case .failure:
        HeartSlash()
        Text("Failed")
          .foregroundStyle(.red)
      case .success:
        Image(systemName: "smallcircle.filled.circle")
          .foregroundStyle(.green)
          .symbolEffect(.pulse.wholeSymbol, options: .speed(0.5))
        Text("Running")
          .foregroundStyle(.green)
      }
    }
  }
}
