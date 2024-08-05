import SwiftUI
import UniformTypeIdentifiers

func selectFolder(_ filePath: String?) -> String? {
  let panel = NSOpenPanel()
  if let filePath = filePath {
    panel.directoryURL = URL(filePath: filePath)
  }
  panel.allowedContentTypes = [.folder]

  panel.canChooseFiles = false
  panel.canChooseDirectories = true
  panel.allowsMultipleSelection = false

  if panel.runModal() == .OK {
    return panel.url?.path
  }
  return nil
}

func selectMultiFiles(_ filePath: String? = nil, utTypes: [UTType]? = nil) -> [URL] {
  let panel = NSOpenPanel()
  if let filePath = filePath {
    panel.directoryURL = URL(filePath: filePath)
  }
  if let utTypes = utTypes {
    panel.allowedContentTypes = utTypes
  }

  panel.canChooseFiles = true
  panel.allowsMultipleSelection = true
  panel.canChooseDirectories = false

  if panel.runModal() == .OK {
    return panel.urls
  }
  return []
}

extension URL {
  // doesn't encode; remove last '/'
  var nicePath: String {
    let path = self.path(percentEncoded: false)
    if path.hasSuffix("/") {
      return String(path.dropLast())
    } else {
      return path
    }
  }
}
