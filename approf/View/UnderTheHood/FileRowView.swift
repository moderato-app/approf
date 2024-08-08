import SwiftUI

struct FileRowView: View {
  @State var failedToReadFileReason: String?
  @State var fileAttrs: FileAttrs?
  @State var hoveringOnLM = false
  
  let filePath: String
  let ignored: Bool
  let isBase: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(filePath.forceCharWrapping)
        .multilineTextAlignment(.leading)
      HStack(alignment: .firstTextBaseline) {
        Button(action: {
          showInFinder(filePath)
        }) {
          Image(systemName: "arrowshape.right.circle.fill")
        }
        .buttonStyle(PlainButtonStyle())
        .help("Show in Finder")
        
        if let fileSize = fileAttrs?.fileSize {
          Text(fileSize.humanReadableFileSize())
            .foregroundStyle(.secondary)
        } else {
          // reserve vertical space before filesize shows up fix unsatalbe row height
          Text("f").opacity(0)
        }

        if let reason = failedToReadFileReason {
          Text("error")
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .background(Rectangle().fill(.red))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .tooltip(delay: 0.3) {
              Text(reason)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            }
        }
        
        Spacer()
        if isBase {
          Text("base")
            .foregroundStyle(.background)
            .padding(.horizontal, 6)
            .background(Rectangle().fill(.teal))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if ignored {
          Text("ignored")
            .foregroundStyle(.background)
            .padding(.horizontal, 6)
            .background(Rectangle().fill(.orange))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        if let lastModified = fileAttrs?.lastModified {
          HStack(alignment: .firstTextBaseline, spacing: 2) {
            if hoveringOnLM {
              Text("Last Modified: ")
            }
            Text(lastModified.humanReadable())
          }
          .foregroundStyle(.secondary)
          .onHover { h in
            withAnimation {
              hoveringOnLM = h
            }
          }
        } else {
          Text("f").opacity(0)
        }
      }
      .font(.footnote)
    }
    .task(priority: .background){
        readFile()
    }
  }
  
  func readFile() {
    if fileAttrs != nil || failedToReadFileReason != nil {
      return
    }
    do {
      let attrs = try FileManager.default.attributesOfItem(atPath: filePath)
      if let fileSize = attrs[.size] as? UInt64, let date = attrs[.modificationDate] as? Date {
        Task { @MainActor in
          withAnimation {
            fileAttrs = .init(fileSize: fileSize, lastModified: date)
          }
        }
      }
    } catch {
      Task { @MainActor in
        withAnimation {
          failedToReadFileReason = error.localizedDescription
        }
      }
    }
  }
  
  struct FileAttrs {
    let fileSize: UInt64
    let lastModified: Date
  }
}
