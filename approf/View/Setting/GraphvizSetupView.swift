import SwiftUI

struct GraphvizSetupView: View {
  @ObservedObject var asm = AppStorageManager.shared
  @State var dotFileExists: (dotPath: String, exist: Bool)? = nil

  var showTitle = true

  var body: some View {
    VStack {
      HStack {
        TextField("", text: $asm.graphvizBinDir)
          .fontDesign(.monospaced)
          .frame(width: 250)
        Button("Open") {
          if let dir = selectFolder(asm.graphvizBinDir) {
            asm.graphvizBinDir = dir
          }
        }
      }
      if let (path, exist) = dotFileExists {
        HStack(spacing: 2) {
          Spacer().frame(width: 2)
          Text(path)
            .fontDesign(.monospaced)
          if exist {
            Text("exists")
              .foregroundStyle(.secondary)
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
          } else {
            Text("doesn't exist")
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.red)
          }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
    }
  }
}
