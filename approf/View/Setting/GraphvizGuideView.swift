// Created for approf in 2024

import SwiftUI

struct GraphvizGuideView: View {
  @ObservedObject var asm = AppStorageManager.shared
  @State var dotFileExists: (dotPath: String, exist: Bool)? = nil
  @FocusState private var isTextFieldFocused: Bool

  var showTitle = true
  var callback: ((Bool) -> Void)? = nil

  var body: some View {
    Group {
      GridRow {
        Text(showTitle ? "Graphviz folder" : "").gridColumnAlignment(.trailing)
        TextField("", text: $asm.graphvizBinDir)
          .fontDesign(.monospaced)
          .frame(width: 250)
          .focused($isTextFieldFocused)
        Button("Open") {
          if let dir = selectFolder(asm.graphvizBinDir) {
            asm.graphvizBinDir = dir
          }
        }
      }
      GridRow {
        Text("").gridColumnAlignment(.trailing)
        HStack(spacing: 2) {
          if let (path, exist) = dotFileExists {
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
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .gridCellColumns(2)
      }
    }
    .onAppear {
      if !asm.graphvizBinDir.isEmpty {
        dotFileExists = dotExist(asm.graphvizBinDir)
        callback?(dotFileExists?.exist ?? false)
      }
    }
    .onAppear(delay: .seconds(0.01)) {
      // prevent auto focus
      isTextFieldFocused = false
    }
    .onChange(of: asm.graphvizBinDir) { _, b in
      if !asm.graphvizBinDir.isEmpty {
        dotFileExists = dotExist(b)
        callback?(dotFileExists?.exist ?? false)
      }
    }
  }
}
