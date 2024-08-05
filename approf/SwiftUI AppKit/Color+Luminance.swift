import SwiftUI

extension Color {
    func luminance() -> Double {
        // Convert SwiftUI Color to CGColor
        guard let cgColor = self.cgColor else {
            return 0.0 // Default luminance if conversion fails
        }

        // Extract RGB values
        let components = cgColor.components
        let red = components?[0] ?? 0.0
        let green = components?[1] ?? 0.0
        let blue = components?[2] ?? 0.0
        
        // Compute luminance.
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }
    
    func isLight() -> Bool {
        return luminance() > 0.5
    }
    
    func adaptedTextColor() -> Color {
        return isLight() ? Color.black : Color.white
    }
}
