import SwiftUI

class CustomWindowController: NSWindowController {
  override func windowDidLoad() {
    super.windowDidLoad()
    window?.tabbingMode = .disallowed // Disable multi-tab. Not working actually.
  }
}
