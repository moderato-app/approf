import SwiftUI

struct AdaptiveForegroundColorModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.foregroundStyle(resolvedColor)
    }
    
    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

extension View {
    func foregroundColor(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveForegroundColorModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
}


struct AdaptiveBackgroundColorModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
      content.backgroundStyle(resolvedColor)
    }
    
    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

extension View {
    func backgroundColor(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveBackgroundColorModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
}
