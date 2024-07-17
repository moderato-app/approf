import Combine
import SwiftUI

struct TooltipModifier<TooltipContent: View>: ViewModifier {
  let delay: Double
  let arrowEdge: Edge
  @ViewBuilder let tooltipContent: () -> TooltipContent

  @State private var hovering = false
  @State private var timerSubscription: AnyCancellable?
  @State private var isPresented = false

  func body(content: Content) -> some View {
    content
      .onHover { isHovering in
        if isHovering {
          startTimer()
        } else {
          stopTimer()
          isPresented = false
        }
      }
      .popover(isPresented: $isPresented, arrowEdge: arrowEdge) {
        tooltipContent()
      }
  }

  private func startTimer() {
    timerSubscription = Timer.publish(every: delay, on: .main, in: .common).autoconnect().sink { _ in
      isPresented = true
      stopTimer()
    }
  }

  private func stopTimer() {
    timerSubscription?.cancel()
    timerSubscription = nil
  }
}

extension View {
  func tooltip<T: View>(delay: Double = 1, arrowEdge: Edge = .top, @ViewBuilder content: @escaping () -> T) -> some View {
    modifier(TooltipModifier(delay: delay, arrowEdge: arrowEdge, tooltipContent: content))
  }
}
