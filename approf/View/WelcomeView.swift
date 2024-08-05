import SwiftUI

struct WelcomeView: View {
  @ObservedObject private var asm = AppStorageManager.shared
  @State private var showGraphvizGuide = false
  @State private var titleHeight: CGFloat = 30

  var body: some View {
    Group {
      if showGraphvizGuide {
        VStack {
          Spacer()
          HStack(alignment: .firstTextBaseline) {
            Image("Gopple").resizable().scaledToFit().frame(height: titleHeight * 2)
            Text(", have you got Graphviz installed?").font(.largeTitle)
              .onGeometryChange(for: CGFloat.self) { proxy in proxy.size.height } action: { titleHeight = $0 }
          }
          Spacer().frame(height: 20)
          Text("Let’s locate the bin folder of Graphviz; it should have the `dot` executable.")
            .font(.title2)
            .fontWeight(.thin)
            .foregroundStyle(.secondary)
          Spacer()
          Grid(alignment: .leadingFirstTextBaseline) {
            GraphvizGuideView(showTitle: false) { exist in
              if exist {
                Task.detached {
                  try await Task.sleep(for: .seconds(1.5))
                  Task { @MainActor in
                    withAnimation(.easeInOut(duration: 1.5)) {
                      showGraphvizGuide = false
                    }
                  }
                }
              } else {
                showGraphvizGuide = true
              }
            }
          }
          Spacer()
          Spacer()
          HStack(alignment: .firstTextBaseline) {
            Text("brew install graphviz")
              .fontDesign(.monospaced)
              .textSelection(.enabled)
            CopyButton {
              "brew install graphviz"
            }
          }
          .padding(30)
        }
      } else {
        OpenFileHint()
      }
    }
    .onAppear {
      showGraphvizGuide = !dotExist(asm.graphvizBinDir).1
    }
  }
}

struct OpenFileHint: View {
  var body: some View {
    VStack(alignment: .leading) {
      Label(title: { Text("Open a file from Finder") }) {
        Image(systemName: "cursorarrow.click.2")
          .foregroundStyle(.blue)
      }
      Label(title: { Text("or") }) {
        Image(systemName: "cursorarrow.click.2")
          .foregroundStyle(.clear)
      }
      Label(title: { Text("drag 'n' drop") }) {
        Image(systemName: "hand.pinch.fill")
          .foregroundStyle(.blue)
      }
    }
    .font(.largeTitle)
  }
}

#Preview {
  WelcomeView()
}
