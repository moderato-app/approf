import SwiftUI

enum PeroidStatus: String {
  case idle = "Idle"
  case terminated = "Terminated"
  case launching = "Launching"
  case failure = "Failed"
  case success = "Running"
}

struct UTHStatusView: View {
  let periodStatus: PeroidStatus

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      switch periodStatus {
      case .idle:
        EmptyView()
      case .terminated:
        Image(systemName: "moon.zzz")
        Text(periodStatus.rawValue)
      case .launching:
        RotatingSF("arrow.clockwise")
          .foregroundStyle(.orange)
        Text(periodStatus.rawValue)
          .foregroundStyle(.orange)
        EmptyView()
      case .failure:
        HeartSlash()
        Text(periodStatus.rawValue)
          .foregroundStyle(.red)
      case .success:
        Image(systemName: "smallcircle.filled.circle")
          .foregroundStyle(.green)
          .symbolEffect(.pulse.wholeSymbol, options: .speed(0.5))
        Text(periodStatus.rawValue)
          .foregroundStyle(.green)
      }
    }
  }
}
