import SwiftUI

extension View {
  @ViewBuilder func onWidthChange(_ action: @escaping (CGFloat) -> Void) -> some View {
    self
      .background(
        GeometryReader { reader in
          Color.clear
            .onChange(of: reader.frame(in: .global).width) { _, newValue in
              action(newValue)
            }
        }
      )
  }
}

extension View {
  static func printChagesWhenDebug() {
    #if DEBUG
    _printChanges()
    #endif
  }
}

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

extension View {
  @ViewBuilder func apply<Content: View>(transform: (Self) -> Content) -> some View {
    transform(self)
  }
}

func showInFinder(_ path: String) {
  let url = URL(fileURLWithPath: path)
  if url.isFileURL {
    NSWorkspace.shared.activateFileViewerSelecting([url])
  }
}

func showInFinder(_ url: URL) {
  if url.isFileURL {
    NSWorkspace.shared.activateFileViewerSelecting([url])
  }
}


public extension View {
    @inlinable
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}
