import ComposableArchitecture
import SwiftUI

struct PProfRowView: View {
  @Bindable var store: StoreOf<DetailFeature>
  var selected: Bool = false

  @State var hoveringOnStatusButton = false

  @State var hoveringOnRow = false
  @State var startButtonWidth = 0.0

  var body: some View {
    row()
      .contentShape(RoundedRectangle(cornerRadius: 8))
      .overlay(alignment: .trailing) {
        startButton()
          .onGeometryChange(for: CGFloat.self) { proxy in proxy.size.width } action: { width in startButtonWidth = width }
          .offset(x: startButtonXOffset)
          .animation(.bouncy, value: startButtonXOffset)
      }
      .onHover { h in
        hoveringOnRow = h
      }
  }

  var startButtonXOffset: CGFloat {
    if !selected, hoveringOnRow {
      switch store.period {
      case .idle, .terminated:
        return 0
      default:
        return startButtonWidth + 50
      }
    }
    return startButtonWidth + 50
  }

  @ViewBuilder
  func startButton() -> some View {
    Button(action: {
      store.send(.onStartButtonTapped)
    }) {
      Rectangle()
        .fill(.tint)
        .aspectRatio(1, contentMode: .fit)
        .overlay {
          Image(systemName: "restart")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .containerRelativeFrame(.vertical) { v, _ in v * 0.4 }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }.buttonStyle(.plain)
  }

  @ViewBuilder
  func runningButton() -> some View {
    Image(systemName: "circle.fill")
      .foregroundStyle(.green)
      .scaleEffect(0.4)
      .transition(.movingParts.iris(blurRadius: 50))
  }

  @ViewBuilder
  func stopButton() -> some View {
    Image(systemName: "square.fill")
      .foregroundStyle(.red.gradient)
      .scaleEffect(1.3)
      .transition(.movingParts.iris(
        blurRadius: 50
      ))
      .onTapGesture {
        store.send(.period(.success(.stop)))
      }
  }

  @ViewBuilder
  func row() -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(store.basic.computedName.forceCharWrapping)
        .font(.title3)
        .fontWeight(.semibold)
        .lineLimit(2)

      let count = store.basic.filePaths.count
      HStack(alignment: .firstTextBaseline) {
        if count > 1 {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Image(systemName: "document")
            Text("×\(count)")
          }
        }

        if store.basic.presentation != .dft {
          Text("\(store.basic.presentation)")
        }

        Spacer()

        let date = store.basic.createdAt
        if date.isToday() {
          Text("Today \(date.formatted(date: .omitted, time: .shortened))")
        } else {
          Text("\(date.formatted(date: .abbreviated, time: .shortened))")
        }

        if store.isRunning {
          ZStack {
            if hoveringOnStatusButton {
              stopButton()
            } else {
              runningButton()
            }
          }
          .onHover { h in
            withAnimation {
              hoveringOnStatusButton = h
            }
          }
        }
      }
      .font(.callout)
      .foregroundStyle(.secondary)
      .animation(.default, value: store.isRunning)
    }
  }
}
