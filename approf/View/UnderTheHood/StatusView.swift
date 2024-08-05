import SwiftUI

enum PeroidStatus {
  case idle
  case terminated
  case launching
  case failure
  case success(snapshot: PProfBasic)

  var displayName: String {
    switch self {
    case .idle: "Idle"
    case .terminated: "Terminated"
    case .launching: "Launching"
    case .failure: "Failed"
    case .success: "Running"
    }
  }
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
        Text(periodStatus.displayName)
      case .launching:
        RotatingSF("arrow.clockwise")
          .foregroundStyle(.orange)
        Text(periodStatus.displayName)
          .foregroundStyle(.orange)
        EmptyView()
      case .failure:
        HeartSlash()
        Text(periodStatus.displayName)
          .foregroundStyle(.red)
      case .success:
        Image(systemName: "smallcircle.filled.circle")
          .foregroundStyle(.green)
          .symbolEffect(.pulse.wholeSymbol, options: .speed(0.5))
        Text(periodStatus.displayName)
          .foregroundStyle(.green)
      }
    }
  }
}
