import Combine
import Foundation
import SwiftUI

struct DelayedHoverModifier: ViewModifier {
  let delay: Double
  @State private var hovering = false
  @State private var timerSubscription: AnyCancellable?

  let onHoverAction: (Bool) -> Void

  func body(content: Content) -> some View {
    content
      .onHover { isHovering in
        if isHovering {
          startTimer()
        } else {
          stopTimer()
          onHoverAction(false)
        }
      }
  }

  private func startTimer() {
    timerSubscription = Timer.publish(every: delay, on: .main, in: .common).autoconnect().sink { _ in
      hovering = true
      onHoverAction(true)
      stopTimer()
    }
  }

  private func stopTimer() {
    timerSubscription?.cancel()
    timerSubscription = nil
  }
}

extension View {
  func delayedHover(_ delay: Double = 1, perform action: @escaping (Bool) -> Void) -> some View {
    modifier(DelayedHoverModifier(delay: delay, onHoverAction: action))
  }
}
