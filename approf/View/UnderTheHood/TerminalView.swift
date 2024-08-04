// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct TerminalView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image(systemName: "apple.terminal")
        //          .foregroundColor(.blue)
        Text("Terminal").foregroundStyle(.secondary)
      }
      if #available(macOS 15.0, *) {
        ScrollableTextBox(heightLimit: 100) {
          Text(store.basic.finalCommandArgs.asCopiable())
          Text(" ")
          Text(store.basic.terminalOutput.map { $0.text }.joined())
        }
        .defaultScrollAnchor(.bottom)
      } else {
        ScrollableTextBox(heightLimit: 100) {
          Text(store.basic.finalCommandArgs.asCopiable())
          Text(" ")
          Text(store.basic.terminalOutput.map { $0.text }.joined())
        }
      }
    }
  }
}
