import ComposableArchitecture
import Pow
import SwiftUI

struct PProfRowView: View {
  @Bindable var store: StoreOf<DetailFeature>
  let running: Bool
  @State var hoveringOnButton = false

  var body: some View {
    HStack {
      textInfo()
      Spacer()
      if running {
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
    .padding(.horizontal, 8)
    .padding(.vertical, 2)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .listRowInsets(.init(top: 0, leading: -6, bottom: 0, trailing: -6))
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
    VStack(alignment: .leading, spacing: 2) {
      Text(store.basic.computedName)
        .font(.title3)
//      HStack(alignment: .firstTextBaseline, spacing: 4) {
//        if let size = size {
//          Text("\(formattedSize(size))")
//            .font(.system(size: 8))
//            .foregroundStyle(.secondary)
//        }
//        if let type = type {
//          Text("\(type)")
//            .font(.caption)
//            .foregroundStyle(.secondary)
//            .padding(.horizontal, 2)
//            .clipShape(RoundedRectangle(cornerRadius: 5))
//            .clipped(antialiased: true)
//        }
//      }
    }
  }

  private func formattedSize(_ size: UInt64) -> String {
    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.countStyle = .file
    return byteCountFormatter.string(fromByteCount: Int64(size))
  }
}
