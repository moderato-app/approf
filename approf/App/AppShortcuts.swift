import SwiftUI
import UniformTypeIdentifiers

struct CMD: Commands {
  @Environment(\.openWindow) var openWindow

  @ObservedObject var asm = AppStorageManager.shared

  var body: some Commands {
    CommandGroup(replacing: CommandGroupPlacement.appInfo) {
      Button("About pprof") {
        self.openWindow(id: "about")
      }
    }
    CommandGroup(after: .newItem) {
      Button("Open") {
        let urls = selectMultiFiles(utTypes: profTypes)
        DateSource.store.send(.drop(.onDropEnds(urls)))
      }
      .keyboardShortcut("o", modifiers: [.command])
    }
    CommandGroup(replacing: CommandGroupPlacement.sidebar) {
      Button("Show/Hide Sidebar") {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
      }
      .keyboardShortcut("l", modifiers: [.command, .shift])
      Button("Show/Hide Sidebar") {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
      }
      .keyboardShortcut("s", modifiers: [.command])
      Picker(selection: self.$asm.colorScheme, label: Text("Appearance")) {
        Text("Automatic").tag(AppColorScheme.automatic)
        Text("Light").tag(AppColorScheme.light)
        Text("Dark").tag(AppColorScheme.dark)
      }
    }
  }
}
