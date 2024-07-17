import ComposableArchitecture
import SwiftUI

struct ImportView: View {
  @Bindable var store: StoreOf<ImportFeature>

  var body: some View {
    VStack {
      List(selection: $store.selection.sending(\.onSelectionChanged)) {
        ForEach(store.basic.filePaths, id: \.self) { filePath in
          row(filePath: filePath)
            .padding(6)
            .contextMenu {
              Button("Delete", systemImage: "trash", role: .destructive) {
                store.send(.onDeleteCommand, animation: .default)
              }
            }
        }
        .onMove { from, to in
          store.send(.onMove(from: from, to: to), animation: .default)
        }
      }

      Spacer()
      HStack {
        commandPreview()
          .padding(20)
        Spacer()
      }
      commands()
      Spacer()
      presentationPicker()
        .padding(.bottom, 20)
    }
    .toolbar {
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
    .onDisappear {
      store.send(.delegate(.onImportViewAutoDismissed))
    }
  }

  @ViewBuilder
  private func commandPreview() -> some View {
    let cmd = store.basic.commandPreview()
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Image(systemName: "command")
          .foregroundColor(.blue)
        Text("Command Preview")
          .foregroundStyle(.secondary)
        if store.basic.presentation == .dft {
          CopyButton {
            store.basic.filePaths.map { CommandLine.commandPreview(.dft, [$0]).asCopiable() }
              .joined(separator: "\n")
          }
        } else {
          CopyButton {
            cmd.asCopiable()
          }
        }
      }
      HStack {
        VStack(alignment: .leading) {
          if store.basic.presentation == .dft {
            ForEach(store.basic.filePaths, id:\ .self) { url in
              let cmd = CommandLine.commandPreview(.dft, [url])
              Text(cmd.asPrintable())
            }
          } else {
            ForEach(cmd.asPrintable().components(separatedBy: "\n"), id: \.self) { line in
              Text(line)
            }
          }
        }
        .padding(8)
        Spacer()
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
      )
    }
  }

  @ViewBuilder
  private func presentationPicker() -> some View {
    VStack(spacing: 2) {
      Text(store.basic.presentation.explanation)
        .font(.footnote)
        .fontDesign(.default)
        .foregroundStyle(.secondary)
        .animation(.easeInOut(duration: 0.1), value: store.basic.presentation)
      Picker("", selection: $store.basic.presentation.sending(\.onpresentationChanged)) {
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
  private func commands() -> some View {
    Rectangle()
      .fill(.clear)
      .frame(width: 1, height: 1)
      .allowsHitTesting(false)
      .sc(.delete, modifiers: [.command]) {
        store.send(.onDeleteCommand, animation: .default)
      }
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

  @ViewBuilder
  private func row(filePath: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(filePath.forceCharWrapping)
        .multilineTextAlignment(.leading)
      HStack(alignment: .firstTextBaseline) {
//        Text("36kb")
//          .foregroundStyle(.secondary)
        Button(action: {
          showInFinder(filePath)
        }) {
          Image(systemName: "arrowshape.right.circle.fill")
        }
        .buttonStyle(PlainButtonStyle())

        Spacer()
        if store.basic.presentation == .diff && filePath == store.basic.filePaths.first {
          Text("Base")
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .background(Rectangle().fill(.teal))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
//        Text("last modified: \(date) ").foregroundStyle(.secondary) + Text("\(time)")
      }
      .font(.footnote)
    }
  }
}

struct ImportViewApp: App {
  let store = Store(initialState:
    ImportFeature.State(basic: Shared(PProfBasic(urls: [
        URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentasdlControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParesdfntalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_object3s.inuse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Library/Applicdfgation\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Library/Applicadfgtion\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.infgfguse_space.002.pb.gz"),
        URL(fileURLWithPath: "/Users/clement/Documents/example.txt"),
        URL(fileURLWithPath: "/Users/username/Documents/example.txt")
      ],
      presentation: .dft))))
  {
    ImportFeature()
  }

  var body: some Scene {
    WindowGroup {
      ImportView(store: store)
    }
  }
}
