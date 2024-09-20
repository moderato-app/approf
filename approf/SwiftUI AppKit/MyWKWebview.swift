import AppKit
import SwiftUI
import WebKit

class MyWKWebView: WKWebView {
  override func scrollWheel(with event: NSEvent) {
    if let u = url, u.path.contains("/ui") {
      log.info("scroll delta: \(event.deltaX):\(event.deltaY)")

      // Create a new mouse event for dragging
      let dragEvent = NSEvent.mouseEvent(
        with: .leftMouseDragged,
        location: event.locationInWindow,
        modifierFlags: event.modifierFlags,
        timestamp: event.timestamp,
        windowNumber: event.windowNumber,
        context: nil,
        eventNumber: event.eventNumber,
        clickCount: 1,
        pressure: event.pressure
      )

      // Create a new mouse event for moving
      let moveEvent = NSEvent.mouseEvent(
        with: .mouseMoved,
        location: event.locationInWindow,
        modifierFlags: event.modifierFlags,
        timestamp: event.timestamp,
        windowNumber: event.windowNumber,
        context: nil,
        eventNumber: event.eventNumber,
        clickCount: 1,
        pressure: event.pressure
      )
            
      // Dispatch the drag and move events
      if let dragEvent = dragEvent {
        super.mouseDragged(with: dragEvent)
      }
      if let moveEvent = moveEvent {
        super.mouseMoved(with: moveEvent)
      }
    } else {
      super.scrollWheel(with: event)
    }
  }
}
