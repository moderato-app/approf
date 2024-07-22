import SwiftUI

class AppStorageManager: ObservableObject {
  static var shared = AppStorageManager()
  // Appearance
  @AppStorage("colorScheme") var colorScheme = AppColorScheme.dark
  @AppStorage("lightsOn") var lightsOn = true
  @AppStorage("materialType") var materialType = MaterialType.ultraThin

  // Function
  @AppStorage("graphvizBinDir") var graphvizBinDir = "/opt/homebrew/bin"

  @AppStorage("selectedSettingsTab")
  var selectedSettingsTab = SettingsTab.appearance
}

enum AppColorScheme: String, CaseIterable, Codable {
  case automatic = "Automatic"
  case light = "Light"
  case dark = "Dark"
}

extension AppStorageManager {
  var computedColorScheme: ColorScheme? {
    switch colorScheme {
    case .light:
      return ColorScheme.light
    case .dark:
      return ColorScheme.dark
    case .automatic:
      return nil
    }
  }
}

enum MaterialType: String, CaseIterable, Codable {
  case ultraThin = "UltraThin", thin = "Thin", regular = "Regular", thick = "Thick", ultraThick = "UltraThick", bar = "Bar"

  var actualMaterial: Material {
    switch self {
    case .regular:
      return Material.regular
    case .thick:
      return Material.thick
    case .thin:
      return Material.thin
    case .ultraThin:
      return Material.ultraThin
    case .ultraThick:
      return Material.ultraThick
    case .bar:
      return Material.bar
    }
  }
}
