import UniformTypeIdentifiers

let allowedImportFileTypes = [
  UTType.data
]

enum PProfError: Error {
  case ordinay(String)
}

struct TerminalRecord: Equatable {
  let date: Date
  let std: Std
  let text: String

  enum Std {
    case out, err
  }
}

struct TrakcingProcess: Identifiable, Equatable {
  var process: Process
  var id: Int32 {
    process.processIdentifier
  }
}
