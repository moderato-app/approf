enum PProfPresentation: String, Codable, CaseIterable {
  case dft = "Isolated", acc = "Accumulate", diff = "Diff"

  var explanation: String {
    switch self {
    case .dft:
      "Run `go tool pprof` on each file separately"
    case .acc:
      "Run `go tool pprof` on all files at once"
    case .diff:
      "Run `go tool pprof` on all files at once, comparing them to the base"
    }
  }

  var next: PProfPresentation {
    var nextIndex = Self.allCases.firstIndex(of: self)! + 1
    if nextIndex == Self.allCases.count {
      nextIndex = 0
    }
    return Self(rawValue: Self.allCases[nextIndex].rawValue)!
  }

  var prev: PProfPresentation {
    var nextIndex = Self.allCases.firstIndex(of: self)! - 1
    if nextIndex < 0 {
      nextIndex = Self.allCases.count - 1
    }
    return Self(rawValue: Self.allCases[nextIndex].rawValue)!
  }
}
