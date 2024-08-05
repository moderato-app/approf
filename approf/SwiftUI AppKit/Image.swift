import SwiftUI
import AppKit

struct RotatingSF: View {
  let systemName: String
  let speed: Double
  @State var degreesRotating = 0.0

  init(_ systemName: String, _ speed: Double = 4.0) {
    self.systemName = systemName
    self.speed = speed
  }
  
  var body: some View {
    Image(systemName: systemName)
      .rotationEffect(.degrees(degreesRotating))
      .onAppear {
        degreesRotating = 0.0
        Task { @MainActor in
          withAnimation(.linear(duration: speed).speed(speed).repeatForever(autoreverses: false)) {
            degreesRotating = 360.0
          }
        }
      }
  }
}


extension NSImage {
    
    /**
     Resizes the image to the given size.
     */
    func resize(withSize targetSize: NSSize) -> NSImage {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        draw(in: CGRect(origin: .zero, size: targetSize), from: CGRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    
    /**
     Resizes the image to the given size maintaining its original aspect ratio.
     */
    func resizeMaintainingAspectRatio(withSize targetSize: NSSize) -> NSImage {
        let newSize: NSSize
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        if(widthRatio > heightRatio) {
            newSize = NSSize(width: floor(size.width * widthRatio), height: floor(size.height * widthRatio))
        } else {
            newSize = NSSize(width: floor(size.width * heightRatio), height: floor(size.height * heightRatio))
        }
        return resize(withSize: newSize)
    }

}
