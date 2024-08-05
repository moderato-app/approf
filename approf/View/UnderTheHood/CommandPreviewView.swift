// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct CommandPreviewView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  var importing: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .bottom, spacing: 4) {
        Image(systemName: "command")
        Text("Command Preview")
          .foregroundStyle(.secondary)
        CopyButton {
          copiable
        }
        Spacer()

        if store.basic.filePaths.count > 1 {
          Picker("", selection: $store.basic.presentation.sending(\.onPresentationChanged)) {
            ForEach(PProfPresentation.allCases, id: \.self) { c in
              Text("\(c.rawValue)")
                .help(c.explanation)
            }
          }
          .pickerStyle(.segmented)
          .labelsHidden()
          .frame(width: 200)
        }
      }
      ScrollableTextBox(heightLimit: 100) {
        if importing && store.basic.presentation == .dft {
          ForEach(store.basic.filePaths, id: \.self) { fp in
            Text(CommandLine.commandPreview(.dft, [fp]).asPrintable())
          }
        } else {
          ForEach(printable, id: \.self) { line in
            Text(line)
          }
        }
      }
    }
  }

  var copiable: String {
    if importing && store.basic.presentation == .dft {
      store.basic.filePaths.map { CommandLine.commandPreview(.dft, [$0]).asCopiable() }
        .joined(separator: "\n")
    } else {
      store.basic.commandPreview().asCopiable()
    }
  }

  var printable: [String] {
    if importing && store.basic.presentation == .dft {
      store.basic.filePaths.map { CommandLine.commandPreview(.dft, [$0]).asPrintable() }
    } else {
      store.basic.commandPreview().asPrintable().components(separatedBy: "\n")
    }
  }
}
