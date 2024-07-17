import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
  @ObservedObject var asm = AppStorageManager.shared
  @Environment(\.dismiss) var dismiss
  @State var dotFileExists: (dotPath: String, exist: Bool)? = nil

  var body: some View {
    Group {
      if #available(macOS 15.0, *) {
        TabView(selection: $asm.selectedSettingsTab) {
          Tab("General", systemImage: "medal.star.fill", value: .general) {
            general()
          }
          Tab("Appearance", systemImage: "paintpalette", value: .appearance) {
            appearance()
          }
          //        Tab("Shortcuts", systemImage: "keyboard", value: .shortcuts) {
          //          ShortcutView()
          //        }
        }
      } else {
        TabView(selection: $asm.selectedSettingsTab) {
          general()
            .tag(SettingsTab.general)
            .tabItem {
              Image(systemName: "medal.star.fill").symbolRenderingMode(.multicolor)
              Text("General")
            }
          appearance()
            .tag(SettingsTab.appearance)
            .tabItem {
              Image(systemName: "paintpalette")
              Text("Appearance")
            }
        }
      }
    }
    .padding(20)
    .frame(width: 600, height: 400)
    .sc(",", modifiers: [.command]) {
      dismiss()
    }
  }

  @ViewBuilder
  func appearance() -> some View {
    Grid(alignment: .leadingFirstTextBaseline) {
      GridRow {
        Label("Color Scheme", systemImage: "paintpalette")
          .symbolRenderingMode(.multicolor)
          .modifier(RippleEffect(at: .zero, trigger: asm.colorScheme))
          .gridColumnAlignment(.trailing)
        Picker("", selection: $asm.colorScheme) {
          ForEach(AppColorScheme.allCases, id: \.self) { c in
            Text("\(c.rawValue)")
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .containerRelativeFrame(.horizontal) { x, _ in
          x / 2
        }
      }
      if #available(macOS 15.0, *) {
        // .containerBackground(asm.materialType.actualMaterial, for: .window) is not available on 14
        GridRow {
          Label("Background", systemImage: "rectangle")
            .modifier(RippleEffect(at: .zero, trigger: asm.materialType))
            .gridColumnAlignment(.trailing)
          Picker("", selection: $asm.materialType) {
            ForEach(MaterialType.allCases, id: \.self) { c in
              Text("\(c.rawValue)")
            }
          }
          .pickerStyle(.automatic)
          .labelsHidden()
          .containerRelativeFrame(.horizontal) { x, _ in
            x / 4
          }
        }
      }
    }
  }

  @ViewBuilder
  func general() -> some View {
    GraphvizGuideView()
  }
}

struct GraphvizGuideView: View {
  @ObservedObject var asm = AppStorageManager.shared
  @State var dotFileExists: (dotPath: String, exist: Bool)? = nil

  var showTitle = true
  var callback: ((Bool) -> Void)? = nil

  var body: some View {
    Grid(alignment: .leadingFirstTextBaseline) {
      GridRow {
        Text(showTitle ? "Graphviz folder" : "").gridColumnAlignment(.trailing)
        TextField("", text: $asm.graphvizBinDir)
          .fontDesign(.monospaced)
          .frame(width: 250)
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
    .onChange(of: asm.graphvizBinDir) { _, b in
      if !asm.graphvizBinDir.isEmpty {
        dotFileExists = dotExist(b)
        callback?(dotFileExists?.exist ?? false)
      }
    }
  }
}

enum SettingsTab: Int {
  case general
  case appearance
  case shortcuts
}

#Preview {
  SettingsView()
}
