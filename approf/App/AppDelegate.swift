import AppKit
import CoreSpotlight
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

    if let window = NSApp.windows.first {
      windowController = CustomWindowController(window: window)
      windowController?.showWindow(self)
    }

    registerSpotlightSearch()
    registerSpotlightSearch2()
    registerSpotlightSearch3()
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
  let userActivity = NSUserActivity(activityType: "the.future.app.approf.approf.alternative")
  userActivity.title = "approf"
  userActivity.keywords = ["pprof", "go", "pp"]
  userActivity.isEligibleForSearch = true
  userActivity.isEligibleForPublicIndexing = true
  userActivity.becomeCurrent()
}

private func registerSpotlightSearch2() {
  let attributeSet = CSSearchableItemAttributeSet(contentType: UTType.data)
  attributeSet.title = "approf"
  attributeSet.contentDescription = "A native macOS app to view pprof profiles"
  attributeSet.keywords = ["pprof", "go", "pp"]
  let item = CSSearchableItem(uniqueIdentifier: "0", domainIdentifier: "the.future.app.approf.approf.alternative", attributeSet: attributeSet)
  CSSearchableIndex.default().indexSearchableItems([item])
}

private func registerSpotlightSearch3() {
  let attributeSet = CSSearchableItemAttributeSet(itemContentType: "application")
  attributeSet.title = "approf"
  attributeSet.keywords = ["pprof", "go", "pp"]
  attributeSet.contentDescription = "A native macOS app to view pprof profiles"

  let item = CSSearchableItem(uniqueIdentifier: "the.future.app.approf.approf.alternative3", domainIdentifier: nil, attributeSet: attributeSet)
  CSSearchableIndex.default().indexSearchableItems([item]) { err in
    if let err = err {
      log.error("CSSearchableIndex.default().indexSearchableItems err: \(err)")
    }
  }
}
