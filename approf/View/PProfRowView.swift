import ComposableArchitecture
import SwiftUI

struct PProfRowView: View {
  @Bindable var store: StoreOf<DetailFeature>

  @State var hoveringOnButton = false
  @State var hoveringOnRow = false

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      name()
      HStack(alignment: .firstTextBaseline) {
        meta()
        Spacer()
        date()
        buttons()
      }
      .font(.callout)
      .foregroundStyle(.secondary)
      .animation(.default, value: store.isRunning)
    }
    .onHover { h in
      withAnimation {
        hoveringOnRow = h
      }
    }
    .contentShape(RoundedRectangle(cornerRadius: 8))
  }

  @ViewBuilder
  func buttons() -> some View {
    ZStack {
      if store.isRunning {
        if hoveringOnButton {
          stopButton()
        } else {
          runningButton()
        }
      } else if showStartButton {
        startButton()
      }
    }
    .onHover { h in
      withAnimation {
        hoveringOnButton = h
      }
    }
  }

  var showStartButton: Bool {
    switch store.period {
    case .idle, .terminated, .failure:
      return hoveringOnRow
    default:
      return false
    }
  }

  @ViewBuilder
  func startButton() -> some View {
    Button(action: { store.send(.onStartButtonTapped) }) {
      Image(systemName: "restart.circle")
        .foregroundStyle(.foreground)
    }
    .buttonStyle(.plain)
    .transition(.movingParts.iris(blurRadius: 50))
    .help("Start pprof process and show the WEB page.")
  }

  @ViewBuilder
  func runningButton() -> some View {
    Image(systemName: "circle.fill")
      .foregroundStyle(.green)
      .scaleEffect(0.4)
      .transition(.movingParts.iris(blurRadius: 50))
      .help("pprof process is running")
  }

  @ViewBuilder
  func stopButton() -> some View {
    Image(systemName: "square.fill")
      .foregroundStyle(.red.gradient)
      .scaleEffect(1.3)
      .transition(.movingParts.iris(blurRadius: 50))
      .onTapGesture {
        store.send(.period(.success(.stop)))
      }
      .help("Terminate pprof process")
  }

  @ViewBuilder
  func name() -> some View {
    Text(store.basic.computedName.forceCharWrapping)
      .font(.title3)
      .fontWeight(.semibold)
      .lineLimit(2)
  }

  @ViewBuilder
  func meta() -> some View {
    let count = store.basic.filePaths.count
    if count > 1 {
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Image(systemName: "document")
        Text("×\(count)")
      }
    }

    if store.basic.presentation != .dft {
      Text("\(store.basic.presentation)")
    }
  }

  @ViewBuilder
  func date() -> some View {
    let date = store.basic.createdAt
    if date.isToday() {
      Text("Today \(date.formatted(date: .omitted, time: .shortened))")
    } else {
      Text("\(date.formatted(date: .abbreviated, time: .shortened))")
    }
  }
}
