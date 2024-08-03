import SwiftUI

extension View {
  /// Add a shortcut to an hidden button
  func sc(_ key: KeyEquivalent, modifiers: EventModifiers = .command, action: @escaping () -> Void) -> some View {
    overlay {
      Button("") {
        action()
      }
      .buttonStyle(.plain)
      .allowsHitTesting(false)
      .hidden()
      .keyboardShortcut(key, modifiers: modifiers)
    }
  }

  func addHiddenView(@ViewBuilder content: () -> some View) -> some View {
    self.background { content().frame(width: 1, height: 1).opacity(0).allowsTightening(false) }
  }
}
