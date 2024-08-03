import ComposableArchitecture
import PopupView
import SwiftUI

struct UnderTheHoodView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  let periodStatus: PeroidStatus
  @ObservedObject var asm = AppStorageManager.shared
  
  var body: some View {
    VStack(spacing: 20) {
      fileList()
        .containerRelativeFrame(.vertical) { y, _ in y / 3 }
      commandPreview()
      Spacer().frame(height: 10)
      terminal()
      HStack {
        VStack(alignment: .leading) {
          HStack {
            UTHStatusView(periodStatus: periodStatus)
            actionButton()
          }
          DetectingHTTPView(basic: store.basic, periodStatus: periodStatus)
        }
        Spacer()
      }
      Spacer()
    }
    .overlay {
      shortcuts()
    }
    .toolbar {
      //      toolbar()
    }
    .popup(item: $store.scope(state: \.destination?.notification, action: \.destination.notification), itemView: { notiStore in
      NotificationView(store: notiStore)
    }) {
      $0.type(.floater())
        .position(.bottomTrailing)
        .animation(.spring())
    }
  }
  
  @ToolbarContentBuilder
  private func toolbar() -> some ToolbarContent {
    ToolbarItem(placement: .destructiveAction) {
      Button("Cancel(ESC)", role: .cancel) {
        store.send(.delegate(.onCancelImportButtonTapped))
      }
    }
    ToolbarItem(placement: .confirmationAction) {
      Button("Done⏎") {
        store.send(.delegate(.onConfirmImportButtonTapped))
      }
      .keyboardShortcut(.return, modifiers: [])
    }
  }
  
  @ViewBuilder
  private func fileList() -> some View {
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
              ignored: store.basic.presentation == .dft && filePath != store.basic.filePaths.first,
              isBase: store.basic.presentation == .diff && filePath == store.basic.filePaths.first,
              delayReadingFile: Duration.milliseconds(100 + 50 * (store.basic.filePaths.firstIndex { $0 == filePath } ?? 2))
            )
            .background {
              // for commands to work
              rowContextMenu(filePath: filePath, deleteDisabled: store.basic.filePaths.count == 1)
                .frame(width: 1, height: 1).opacity(0).allowsHitTesting(false)
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
            let urls = selectMultiFiles(utTypes: profTypes)
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
  private func commandPreview() -> some View {
    let cmd = store.basic.commandPreview()
    VStack(alignment: .leading) {
      HStack(alignment: .bottom, spacing: 4) {
        Image(systemName: "command")
        //          .foregroundColor(.blue)
        Text("Command Preview")
          .foregroundStyle(.secondary)
        CopyButton {
          cmd.asCopiable()
        }
        Spacer()
        
        if store.basic.filePaths.count > 1 {
          Picker("", selection: $store.basic.presentation.sending(\.onPresentationChanged).animation()) {
            ForEach(PProfPresentation.allCases, id: \.self) { c in
              Text("\(c.rawValue)")
            }
          }
          .pickerStyle(.segmented)
          .labelsHidden()
          .frame(width: 200)
        }
      }
      ScrollableTextBox(heightLimit: 100) {
        ForEach(cmd.asPrintable().components(separatedBy: "\n"), id: \.self) { line in
          Text(line)
        }
      }
    }
  }
  
  @ViewBuilder
  private func rowContextMenu(filePath: String, deleteDisabled: Bool) -> some View {
    Button("Show in Finder") {
      NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: filePath)])
    }
    .keyboardShortcut("j", modifiers: [.command, .shift])
    Button(action: {
      store.send(.onDeleteMenuTapped(filePath), animation: .default)
    }) {
      Text("Delete").foregroundStyle(.red)
    }
    .foregroundStyle(.red)
    .keyboardShortcut(.delete, modifiers: [.command])
    .disabled(deleteDisabled)
  }
  
  @ViewBuilder
  private func presentationPicker() -> some View {
    VStack(spacing: 2) {
      Text(store.basic.presentation.explanation)
        .font(.footnote)
        .fontDesign(.default)
        .foregroundStyle(.secondary)
        .animation(.easeInOut(duration: 0.1), value: store.basic.presentation)
      Picker("", selection: $store.basic.presentation.sending(\.onPresentationChanged)) {
        ForEach(PProfPresentation.allCases, id: \.self) { c in
          Text("\(c.rawValue)")
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .containerRelativeFrame(.horizontal) { v, _ in v * 0.5 }
    }
  }
  
  @ViewBuilder
  private func terminal() -> some View {
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
  
  @ViewBuilder
  private func actionButton() -> some View {
    switch periodStatus {
    case .idle:
      EmptyView()
    case .terminated:
      Button("Launch") {
        store.send(.delegate(.launchButtonTapped))
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case .failure:
      Button("Relaunch") {
        store.send(.delegate(.launchButtonTapped))
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case .success:
      HStack(alignment: .firstTextBaseline) {
        Button("Stop") {
          store.send(.delegate(.stopButtonTapped))
        }
        Button("go to web") {
          store.send(.delegate(.goToWEBButtonTapped))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .fontDesign(.rounded)
      }
    case .launching:
      Button("Cancel") {
        store.send(.delegate(.stopButtonTapped))
      }
    }
  }
  
  @ViewBuilder
  private func shortcuts() -> some View {
    Rectangle()
      .fill(.clear)
      .frame(width: 1, height: 1)
      .allowsHitTesting(false)
      .sc(.upArrow, modifiers: [.command, .shift]) {
        store.send(.onMoveUpCommand, animation: .default)
      }
      .sc(.downArrow, modifiers: [.command, .shift]) {
        store.send(.onMoveDownCommand, animation: .default)
      }
      .sc(.rightArrow, modifiers: []) {
        store.send(.onNextPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: []) {
        store.send(.onNextPresentationCommand, animation: .default)
      }
      .sc(.leftArrow, modifiers: []) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: [.control]) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: [.shift]) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
  }
}
