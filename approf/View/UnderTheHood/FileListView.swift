// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct FileListView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  var importing: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Image(systemName: "folder")
        //          .foregroundColor(.blue)
        Text("Files")
          .foregroundStyle(.secondary)
      }
      VStack(spacing: 0) {
        List(selection: $store.selection.sending(\.onSelectionChanged)) {
          ForEach(store.basic.filePaths, id: \.self) { filePath in
            FileRowView(
              filePath: filePath,
              ignored: !importing && (store.basic.presentation == .dft && filePath != store.basic.filePaths.first),
              isBase: store.basic.presentation == .diff && filePath == store.basic.filePaths.first
            )
            .addHiddenView(filePath) {
              if store.selection == filePath {
                rowContextMenu(filePath: filePath, deleteDisabled: store.basic.filePaths.count == 1)
              }
            }
            .contextMenu {
              rowContextMenu(filePath: filePath, deleteDisabled: store.basic.filePaths.count == 1)
            }
          }
          .onMove { from, to in
            store.send(.onMove(from: from, to: to), animation: .default)
          }
        }
        .scrollContentBackground(.hidden)

        Divider()

        HStack(alignment: .center, spacing: 2) {
          Button(action: {
            let urls = selectMultiFiles(utTypes: allowedImportFileTypes)
            if !urls.isEmpty {
              let filePaths = urls.map { $0.path(percentEncoded: false) }
              store.send(.onSelectFilesEnd(filePaths))
            }
          }) {
            Image(systemName: "rectangle.fill")
              .opacity(0.001)
              .overlay {
                Image(systemName: "plus")
              }
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())

          Divider().frame(height: 14)
          Button(action: { store.send(.onDeleteSelectedCommand) }) {
            Image(systemName: "rectangle.fill")
              .opacity(0.001)
              .overlay {
                Image(systemName: "minus")
              }
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
          Spacer()
        }
        .padding(.leading, 8)
        .padding(.vertical, 3)
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(.bar)
          .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
      )
    }
  }

  @ViewBuilder
  private func rowContextMenu(filePath: String, deleteDisabled: Bool) -> some View {
    Button("Show in Finder") {
      showInFinder(filePath)
    }
    .keyboardShortcut("j", modifiers: [.command, .shift])

    Button(action: {
      store.send(.onMoveUpCommand, animation: .default)
    }) {
      Text("Move Up")
    }
    .keyboardShortcut(.upArrow, modifiers: [.command])

    Button(action: {
      store.send(.onMoveDownCommand, animation: .default)
    }) {
      Text("Move Down")
    }
    .keyboardShortcut(.downArrow, modifiers: [.command])

    Button(action: {
      store.send(.onDeleteMenuTapped(filePath), animation: .default)
    }) {
      Text("Delete").foregroundStyle(.red)
    }
    .keyboardShortcut(.delete, modifiers: [.command])
    .disabled(deleteDisabled)
  }
}
