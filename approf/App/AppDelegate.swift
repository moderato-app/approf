import AppKit
import Logging

var log = Logger(label: "mac-pprof")

class AppDelegate: NSObject, NSApplicationDelegate {
  var windowController: CustomWindowController?

  func application(_ application: NSApplication, open urls: [URL]) {
    log.info("application open urls: \(urls)")
    DateSource.store.send(.drop(.onDropEnds(urls)))
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    log.logLevel = .debug

    let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .localDomainMask)
    log.debug("documentDirectory:")
    log.debug("\(urls)")

    if let window = NSApp.windows.first {
      windowController = CustomWindowController(window: window)
      windowController?.showWindow(self)
    }

//    showTrafficLights(window, false)
  }

  func applicationDidUpdate(_ notification: Notification) {
//    guard let window = NSApp.keyWindow else { return }
//    // avoid interfering with traffic lights in full screen mode to prevent glitches.
//    if !window.styleMask.contains(.fullScreen) {
//      showTrafficLights(window, UIState.shared.mouseInsideWindow)
//    }
  }

  func applicationWillTerminate(_ notification: Notification) {
    log.info("applicationWillTerminate")
    DateSource.store.send(.onAppTermination)
  }
}

func showTrafficLights(_ window: NSWindow, _ show: Bool) {
  NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.5 // Set the animation duration

    if let closeButton = window.standardWindowButton(.closeButton) {
      closeButton.animator().alphaValue = show ? 1.0 : 0.0
    }
    if let miniaturizeButton = window.standardWindowButton(.miniaturizeButton) {
      miniaturizeButton.animator().alphaValue = show ? 1.0 : 0.0
    }
    if let zoomButton = window.standardWindowButton(.zoomButton) {
      zoomButton.animator().alphaValue = show ? 1.0 : 0.0
    }
  }
}

private func registerSpotlightSearch() {
  let userActivity = NSUserActivity(activityType: "com.example.myApp.alternative")
  userActivity.title = "approf"
  userActivity.keywords = ["pprof", "go"]
  userActivity.isEligibleForSearch = true
  userActivity.isEligibleForPublicIndexing = true
  userActivity.becomeCurrent()
}