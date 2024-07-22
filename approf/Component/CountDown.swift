import Combine
import SwiftUI

class CountDown: ObservableObject {
  @Published var remainingSeconds: Int
  private var timer: AnyCancellable?

  init(_ seconds: Int) {
    self.remainingSeconds = seconds
  }

  func start() {
    
    timer = Timer.publish(every: 1.0, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.tick() // Separate the tick logic into a function
      }
  }

  private func tick() {
    remainingSeconds -= 1
    if remainingSeconds <= 0 {
      destroy()
    }
  }

  func destroy() {
    timer?.cancel()
    timer = nil
  }

  deinit {
    destroy() // Ensure the timer is stopped when the object is deallocated
  }
}
