import SwiftUI

struct RotatingSF: View {
  let systemName: String
  let speed: Double
  @State var degreesRotating = 0.0

  init(_ systemName: String, _ speed: Double = 4.0) {
    self.systemName = systemName
    self.speed = speed
  }
  
  var body: some View {
    Image(systemName: systemName)
      .rotationEffect(.degrees(degreesRotating))
      .onAppear {
        degreesRotating = 0.0
        Task { @MainActor in
          withAnimation(.linear(duration: speed).speed(speed).repeatForever(autoreverses: false)) {
            degreesRotating = 360.0
          }
        }
      }
  }
}
