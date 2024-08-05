import Foundation
import Logging
import Network

extension String: @retroactive Error {}

func findRandomAvailablePort() throws -> UInt16 {
  let parameters = NWParameters.tcp
  parameters.requiredLocalEndpoint = NWEndpoint.hostPort(host: .ipv4(.loopback), port: .any)

  let listener = try NWListener(using: parameters)

  guard let port = listener.port else {
    throw thr("port is nil")
  }

  listener.cancel()

  return port.rawValue
}

func createTemporaryDirectory() -> URL? {
  let tempDirectoryURL = FileManager.default.temporaryDirectory
  let temporaryDirectoryName = UUID().uuidString
  let temporaryDirectoryURL = tempDirectoryURL.appendingPathComponent(temporaryDirectoryName, isDirectory: true)

  do {
    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    return temporaryDirectoryURL
  } catch {
    print("Error creating temporary directory: \(error)")
    return nil
  }
}

func detectHttpOk(httpUrl: URL, followIndirect: Bool = false, interval: Duration = .seconds(0.1), bodyShouldContain: String? = nil) async throws(Error) {
  var tried = 0
  while true {
    if tried > 0 {
      log.debug("detectHttpOk will continue, tried:\(tried)")
      try await Task.sleep(for: interval)
    }

    tried += 1

    var d: Data?
    var r: URLResponse?
    do {
      (d, r) = try await URLSession.shared.data(for: URLRequest(url: httpUrl))
    } catch {
      log.debug("detecting http liveness: failed, Unexpected response body: \(error))")
      continue
    }

    let data = d!
    let response = r!

    if let httpResponse = response as? HTTPURLResponse {
      if (200 ... 299).contains(httpResponse.statusCode) {
        if let text = bodyShouldContain {
          let dataString = String(data: data, encoding: .utf8)
          if dataString?.contains(text) ?? false {
            log.debug("detecting http liveness: success)")
            return
          } else {
            log.debug("detecting http liveness: failed, Unexpected response body: \(String(describing: dataString))")
          }
        } else {
          log.debug("detecting http liveness: success)")
          return
        }
      } else {
        log.debug("detecting http liveness: failed, Request failed with status code: \(httpResponse.statusCode)")
      }
    }
    try await Task.sleep(for: interval)
  }
}

func detectPipeContains(_ pipe: Pipe, _ shouldStartWith: String) async throws(Error) {
  let handle = pipe.fileHandleForReading

  var read = ""

  while let data = try handle.readToEnd(),
        let output = String(data: data, encoding: .utf8)
  {
    read.append(output)

    if read.count >= shouldStartWith.count {
      if read.starts(with: shouldStartWith) {
        log.debug("detecting pipe: success)")
        return
      } else {
        throw thr("Unexpected output: \(read)")
      }
    } else {
      if shouldStartWith.starts(with: read) {
        // continue to read
        continue
      } else {
        throw thr("Unexpected output: \(read)")
      }
    }
  }
  throw thr("Unexpected output: \(read)")
}

extension Logger {
  func infoString(_ s: String) {
    self.info("\(s)")
  }

  func thr(_ s: String) throws {
    self.error("\(s)")
    throw s
  }

  func thr<T>(_ e: T) -> T where T: Error {
    self.error("== Throwing \(e.self) ==")
    return e
  }
}

func thr<T>(_ e: T) -> T where T: Error {
  log.error("== Throwing \(e.self) ==")
  return e
}

func readFirstLine(from fileURL: URL) -> String? {
  do {
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    let lines = content.components(separatedBy: .newlines)
    return lines.first
  } catch {
    print("Error reading file: \(error.localizedDescription)")
    return nil
  }
}

func getAppVersion() -> String {
  if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
     let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
  {
    return "\(version) (\(build))"
  }
  return ""
}

extension String {
  // "🇩🇪€4€9".extract("[0-9]") ==> ["4", "9"]
  func extract(regex: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let results = regex.matches(in: self,
                                  range: NSRange(self.startIndex..., in: self))
      return results.map {
        String(self[Range($0.range, in: self)!])
      }
    } catch {
      log.error("invalid regex: \(error.localizedDescription)")
      return []
    }
  }

  func extractPort() -> UInt16? {
    let pattern = "Serving web UI on http://localhost:(\\d+)"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])

    if let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
      if let range = Range(match.range(at: 1), in: self) {
        let port = UInt16(self[range])
        return port
      }
    }
    return nil
  }
}

// How to force SwiftUI Text to ‘break by character
// https://medium.com/@Jager-yoo/watchos-how-to-force-swiftui-text-to-break-by-character-cd22526568b8
extension String {
  /// Forces the string to apply the break by character mode.
  ///
  /// Text("This is a long text.".forceCharWrapping)
  var forceCharWrapping: Self {
    self.map { String($0) }.joined(separator: "\u{200B}")
  }
}

extension String {
  var asUrl: URL? {
    URL(string: self)
  }
}

extension UInt64 {
  /// Returns a human-readable file size string (e.g., "18B", "20KB", "20MB").
  func humanReadableFileSize() -> String {
    let size = Double(self)
    if size < 1024 {
      return "\(self)B"
    }
    let units = ["KB", "MB", "GB", "TB", "PB"]
    var unitIndex = 0
    var adjustedSize = size / 1024.0
    while adjustedSize >= 1024 && unitIndex < units.count - 1 {
      adjustedSize /= 1024
      unitIndex += 1
    }
    return String(format: "%.1f%@", adjustedSize, units[unitIndex])
  }
}

func getFileSize(atPath path: String) -> UInt64? {
  do {
    let attributes = try FileManager.default.attributesOfItem(atPath: path)
    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
      return fileSize
    }
  } catch {
    print("Error: \(error)")
  }
  return nil
}

func getFileSize(atURL url: URL) -> UInt64? {
  return getFileSize(atPath: url.path)
}

extension String {
  var fileSize: UInt64? {
    getFileSize(atPath: self)
  }
}

extension URL {
  func replaceHomeWithTilde() -> String {
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser

    if self.path.hasPrefix(homeDirectory.path) {
      let relativePath = self.path(percentEncoded: false).replacingOccurrences(of: homeDirectory.path, with: "~")
      return relativePath
    } else {
      return self.path(percentEncoded: false)
    }
  }
}
