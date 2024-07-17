import ComposableArchitecture
import SwiftUI

@main
struct MyMain {
  static func main() {
    if #available(macOS 15.0, *) {
      MacOS15App.main()
    } else {
      MacOS14App.main()
    }
  }
}

@available(macOS 15.0, *)
struct MacOS15App: App {
  @ObservedObject var asm = AppStorageManager.shared
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Window("approf", id: "main") {
      ContentView(store: DateSource.store)
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(asm.materialType.actualMaterial, for: .window)
        .preferredColorScheme(asm.computedColorScheme)
    }
    .defaultWindowPlacement { _, context in
      let displayBounds = context.defaultDisplay.visibleRect
      let size = CGSize(width: displayBounds.width * 0.8, height: displayBounds.height * 0.8)
      return WindowPlacement(size: size)
    }
    .commands {
      CMD()
    }

    Settings{
      SettingsView()
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(.ultraThinMaterial, for: .window)
        .preferredColorScheme(asm.computedColorScheme)
    }
    .windowManagerRole(.associated)

    Window("About approf", id: "about") {
      AboutView()
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(.ultraThinMaterial, for: .window)
        .windowMinimizeBehavior(.disabled)
        .preferredColorScheme(asm.computedColorScheme)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)
  }
}

struct MacOS14App: App {
  @ObservedObject var asm = AppStorageManager.shared
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Window("approf", id: "main") {
      ContentView(store: DateSource.store)
        .preferredColorScheme(asm.computedColorScheme)
    }
    .handlesExternalEvents(matching: ["*"])
    .commands {
      CMD()
    }

    Settings {
      SettingsView()
        .preferredColorScheme(asm.computedColorScheme)
    }

    Window("About approf", id: "about") {
      AboutView()
        .preferredColorScheme(asm.computedColorScheme)
    }
    .windowResizability(.contentSize)
  }
}

func shrinkToFit(ideal: CGSize, bounds: CGRect) -> CGSize {
  let widthRatio = bounds.width / ideal.width
  let heightRatio = bounds.height / ideal.height

  let scale = min(widthRatio, heightRatio)

  return CGSize(width: ideal.width * scale, height: ideal.height * scale)
}
