import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
  static let sidebar = Self("Show/Hide Sidebar", default: .init(.l, modifiers: [.command, .shift]))
  static let refresh = Self("Refresh the Page", default: .init(.r, modifiers: [.command]))
  static let openAFile = Self("Open a File", default: .init(.t, modifiers: [.command]))
  static let closeTab = Self("Close Tab", default: .init(.w, modifiers: [.command]))
  static let stop = Self("Stop", default: .init(.c, modifiers: [.control]))
}

struct ShortcutView: View {
  var body: some View {
    Form {
      KeyboardShortcuts.Recorder("Show/Hide Sidebar", name: .sidebar)
      KeyboardShortcuts.Recorder("Refresh the Page", name: .refresh)
      KeyboardShortcuts.Recorder("Open a File", name: .openAFile)
      KeyboardShortcuts.Recorder("Close Tab", name: .closeTab)
      KeyboardShortcuts.Recorder("Stop", name: .stop)
    }
  }
}

#Preview {
  ShortcutView()
}
