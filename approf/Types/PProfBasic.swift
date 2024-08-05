import Foundation

struct PProfBasic: Equatable, Identifiable, Codable {
  var id: UUID
  var name: String
  var filePaths: [String]
  var createdAt: Date
  var presentation: PProfPresentation
  var httpDetectLog: [HTTPResult]
  var terminalOutput: [TerminalRecord]
  var finalCommandArgs: [CommandLine.CommandArg]

  init(filePaths: [String], presentation: PProfPresentation = .dft, httpDetectLog: [HTTPResult] = [], terminalOutput: [TerminalRecord] = [], finalCommandArgs: [CommandLine.CommandArg] = []) {
    self.id = UUID()
    self.name = ""
    self.filePaths = filePaths
    self.createdAt = Date()
    self.presentation = presentation
    self.httpDetectLog = httpDetectLog
    self.terminalOutput = terminalOutput
    self.finalCommandArgs = finalCommandArgs
  }

  init(urls: [URL], presentation: PProfPresentation = .dft) {
    let filePaths = urls.map { $0.path(percentEncoded: false) }
    self.init(filePaths: filePaths, presentation: presentation)
  }

  // Custom encoding
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.name, forKey: .name)
    try container.encode(self.filePaths, forKey: .filePaths)
    try container.encode(self.createdAt, forKey: .createdAt)
    try container.encode(self.presentation, forKey: .presentation)
  }

  // Custom decoding
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.filePaths = try container.decode([String].self, forKey: .filePaths)
    self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    self.presentation = try container.decode(PProfPresentation.self, forKey: .presentation)
    self.httpDetectLog = []
    self.terminalOutput = []
    self.finalCommandArgs = []
  }

  // Define coding keys
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case filePaths
    case createdAt
    case presentation
  }
}

extension PProfBasic {
  static let mock = PProfBasic(
    filePaths: ["/Users/mark/projects/mark/pprof"],
    httpDetectLog: [
      HTTPResult.http(code: 200, html: "<?xml version=\"1.0\" encoding=\"UTF - 8\"?>"),
      HTTPResult.http(code: 403, html: "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"),
    ],
    terminalOutput: [
      .init(date: Date.now, std: .err, text: "remote: Enumerating objects: 216520, done."),
      .init(date: Date.now, std: .out, text: "Resolving deltas: 100% (195133/195133), done.."),
    ],
    finalCommandArgs: [.string("pprof"), .string("-http=:"), .filePath("/Users/mark/projects/mark/pprof")]
  )
}

extension PProfBasic {
  var computedName: String {
    if !name.isEmpty {
      return name
    }

    guard let firstFile = self.filePaths.first else {
      return "No file"
    }

    guard let firstFileName = firstFile.asUrl?.lastPathComponent else {
      return "No file"
    }
    return firstFileName
  }
}

extension PProfBasic {
  func commandArgs() -> [CommandLine.CommandArg] {
    CommandLine.commandArgs(self.presentation, self.filePaths)
  }

  func commandPreview() -> [CommandLine.CommandArg] {
    CommandLine.commandPreview(self.presentation, self.filePaths)
  }
}
