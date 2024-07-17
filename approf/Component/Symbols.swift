import SwiftUI

struct HeartSlash: View {
  @State var slashed = false

  var body: some View {
    Image(systemName: slashed ? "heart.slash.fill" : "heart.fill")
      .symbolRenderingMode(.multicolor)
      .contentTransition(.symbolEffect(.replace))
      .onAppear(delay: .seconds(0.25)) {
        withAnimation {
          slashed.toggle()
        }
      }
      .onDisappear {
        withAnimation {
          slashed.toggle()
        }
      }
  }
}

struct LightbulbSlash: View {
  @Binding var lightsOn: Bool

  var body: some View {
    Image(systemName: lightsOn ? "lightbulb" : "lightbulb.slash")
      .contentTransition(.symbolEffect(.replace))
  }
}
