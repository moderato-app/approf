import SwiftUI

public extension View {
  func onAppear(delay: Duration, action: @escaping () -> Void) -> some View {
    task {
      do {
        try await Task.sleep(for: delay)
      } catch { // Task canceled
        return
      }

      await MainActor.run {
        action()
      }
    }
  }

  func task(delay: Duration, action: @escaping () -> Void) -> some View {
    task {
      do {
        try await Task.sleep(for: delay)
      } catch { // Task canceled
        return
      }

      await MainActor.run {
        action()
      }
    }
  }
}
