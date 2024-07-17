import Foundation

extension CommandLine {
  enum CommandArg: Equatable {
    case string(String), url(URL), filePath(String), newLine
  }

  static func commandPreview(_ presentation: PProfPresentation, _ filePaths: [String]) -> [CommandArg] {
    var args = commandArgs(presentation, filePaths)
    args.insert(.string("go tool pprof"), at: 0)
    return args
  }

  static func commandPreview(_ presentation: PProfPresentation, _ urls: [URL]) -> [CommandArg] {
    let filePahts = urls.map { $0.path(percentEncoded: false) }
    var args = commandArgs(presentation, filePahts)
    args.insert(.string("go tool pprof"), at: 0)
    return args
  }

  static func commandArgs(_ presentation: PProfPresentation, _ urls: [URL]) -> [CommandArg] {
    let filePahts = urls.map { $0.path(percentEncoded: false) }
    return commandArgs(presentation, filePahts)
  }

  static func commandArgs(_ presentation: PProfPresentation, _ filePaths: [String]) -> [CommandArg] {
    var preview: [CommandArg] = []
    preview.append(.string("-http=:"))
    preview.append(.string("-no_browser"))
    switch presentation {
    case .dft:
      preview.append(.filePath(filePaths.first ?? ""))
    case .acc:
      preview.append(.newLine)
      for fp in filePaths {
        preview.append(.filePath(fp))
        preview.append(.newLine)
      }
      if case .newLine = preview.last {
        preview.removeLast()
      }
    case .diff:
      preview.append(.string("-diff_base"))
      preview.append(.newLine)
      for fp in filePaths {
        preview.append(.filePath(fp))
        preview.append(.newLine)
      }
      if case .newLine = preview.last {
        preview.removeLast()
      }
    }
    return preview
  }
}

extension [CommandLine.CommandArg] {
  func asProcessArgs() -> [String] {
    var args: [String] = []
    for arg in self {
      switch arg {
      case let .string(a), let .filePath(a):
        args.append(a)
      case let .url(a):
        args.append(a.path(percentEncoded: false))
      case .newLine:
        continue
      }
    }
    return args
  }

  func asCopiable() -> String {
    return self.map { arg in
      switch arg {
      case let .string(a):
        a.trimmingCharacters(in: .whitespacesAndNewlines)
      case let .url(a):
        a.path(percentEncoded: false).replacingOccurrences(of: " ", with: "\\ ")
      case let .filePath(a):
        a.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "\\ ")
      case .newLine:
        "\\\n"
      }
    }.joined(separator: " ")
  }

  func asPrintable() -> String {
    return self.map { arg in
      switch arg {
      case let .string(a):
        a.trimmingCharacters(in: .whitespacesAndNewlines)
      case let .url(a):
        a.path(percentEncoded: false)
      case let .filePath(a):
        a.trimmingCharacters(in: .whitespacesAndNewlines)
      case .newLine:
        "\\\n"
      }
    }.joined(separator: " ").forceCharWrapping
  }
}
