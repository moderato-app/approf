import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
  @StateObject var asm = AppStorageManager.shared
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
  func general() -> some View {
    VStack {
      Grid(alignment: .leadingFirstTextBaseline) {
        GraphvizGuideView()
        DefaultGzAppView()
      }
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
}



enum SettingsTab: Int {
  case general
  case appearance
  case shortcuts
}

#Preview {
  SettingsView()
}
