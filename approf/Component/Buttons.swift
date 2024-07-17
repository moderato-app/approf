import SwiftUI
import Pow

struct CopyButton: View {
  let textGenerator: () -> String
  @State var clicked = false

  init(textGenerator: @escaping () -> String) {
    self.textGenerator = textGenerator
  }
  
  var body: some View {
    Button(action: {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(textGenerator(), forType: .string)
      withAnimation {
        clicked = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        withAnimation {
          clicked = false
        }
      }
    }) {
      if clicked {
        Image(systemName: "checkmark.circle")
          .foregroundStyle(.green)
          .transition(
            .movingParts.pop(.green)
          )
      } else {
        Image(systemName: icon)
      }
    }
    .buttonStyle(PlainButtonStyle())
  }

  var icon: String {
    if #available(macOS 15.0, *) {
      "document.on.clipboard"
    } else {
      "doc.on.clipboard"
    }
  }
}

struct LightsOnButton: View {
  @Binding var lightsOn: Bool
  @State var clickedDate: Date?

  var body: some View {
    Button(action: {
      let now = Date()
      if let lastClicked = clickedDate, now.timeIntervalSince(lastClicked) < 1.5 {
        // to avoid wkwebview glitch, do nothing if the button was clicked in the past 1.5 second
        return
      }
      withAnimation {
        lightsOn.toggle()
      }
      clickedDate = now
    }) {
      LightbulbSlash(lightsOn: $lightsOn)
    }
  }
}
