import Testing
import AppKit

@testable import pprof

struct pprofTests {

    @Test func testExample() async throws {
      let str = "Serving web UI on http://localhost:56010"
      
      let pattern = "Serving web UI on http://localhost:(\\d+)"
      let regex = try! NSRegularExpression(pattern: pattern, options: [])

      if let match = regex.firstMatch(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count)) {
          if let range = Range(match.range(at: 1), in: str) {
              let port = String(str[range])
              print("Extracted port number: \(port)")
          }
      } else {
          print("No match found")
      }

    }

}
