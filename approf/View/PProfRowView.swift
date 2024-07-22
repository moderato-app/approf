import ComposableArchitecture
import Pow
import SwiftUI

struct PProfRowView: View {
  @Bindable var store: StoreOf<DetailFeature>
  @State var hoveringOnButton = false

  var body: some View {
    textInfo()
      .contentShape(RoundedRectangle(cornerRadius: 8))
  }

  @ViewBuilder
  func runningButton() -> some View {
    Image(systemName: "circle.fill")
      .foregroundStyle(.green)
      .scaleEffect(0.4)
      .transition(.movingParts.iris(
        blurRadius: 50
      ))
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
  func textInfo() -> some View {
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
            if hoveringOnButton {
              stopButton()
            } else {
              runningButton()
            }
          }
          .onHover { h in
            withAnimation {
              hoveringOnButton = h
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
