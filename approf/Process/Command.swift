import Foundation

// create the process without running it
func createPProfProcess(_ args: [CommandLine.CommandArg]) throws(PProfError) -> ([CommandLine.CommandArg], Process, AsyncStream<String>) {
  let pprofPath = "\(Bundle.main.bundlePath)/Contents/Frameworks/pprof"
  let process = Process()
  process.executableURL = URL(fileURLWithPath: pprofPath)
  process.arguments = args.asProcessArgs()
  let finalCommandArgs = [CommandLine.CommandArg.filePath(pprofPath)] + args

  var environment = ProcessInfo.processInfo.environment
  let additional = AppStorageManager.shared.graphvizBinDir.replacingOccurrences(of: ":", with: "")
  environment["PATH"] = "\(additional):\(environment["PATH"] ?? "")"
  log.info("PATH:\(String(describing: environment["PATH"]))")
  process.environment = environment

  let pipe = Pipe()
  process.standardOutput = pipe
  process.standardError = pipe

  log.debug("pipe created. fileDescriptor:  \(pipe.fileHandleForReading.fileDescriptor)")

  let terminalStream = AsyncStream<String> { con in
    let handle = pipe.fileHandleForReading

    handle.readabilityHandler = { fh in
      if let output = String(data: fh.availableData, encoding: .utf8) {
        con.yield(output)
      }
      // read only once to get the port or an error, preventing next reading operation from blocking loop
      con.finish()
      handle.readabilityHandler = nil
    }

    process.terminationHandler = { _ in
      con.finish()
      do {
        try handle.close()
      } catch {
        log.error("failed to close pipe: \(error.localizedDescription)")
      }
    }
  }

  return (finalCommandArgs, process, terminalStream)
}

func detectHttpOk2(httpUrl: URL, followIndirect: Bool = false, bodyShouldContain: String? = nil) async -> (Bool, HTTPResult) {
  var d: Data?
  var r: URLResponse?
  do {
    (d, r) = try await URLSession.shared.data(for: URLRequest(url: httpUrl))
  } catch {
    log.debug("detecting http liveness: failed, Unexpected response body: \(error))")
    return (false, HTTPResult.err(error.localizedDescription))
  }

  let data = d!
  let response = r!

  let dataString = String(data: data, encoding: .utf8) ?? ""
  if let httpResponse = response as? HTTPURLResponse {
    if (200 ... 299).contains(httpResponse.statusCode) {
      if let text = bodyShouldContain {
        if dataString.contains(text) {
          log.debug("detecting http liveness: success)")
          return (true, HTTPResult.http(code: httpResponse.statusCode, html: dataString))
        } else {
          let trunc = dataString.prefix(100)
          log.debug("detecting http liveness: failed, Unexpected response body: \(trunc)")
          return (false, HTTPResult.http(code: httpResponse.statusCode, html: dataString))
        }
      } else {
        log.debug("detecting http liveness: success)")
        return (true, HTTPResult.http(code: httpResponse.statusCode, html: dataString))
      }
    } else {
      log.debug("detecting http liveness: failed, Request failed with status code: \(httpResponse.statusCode)")
      return (false, HTTPResult.http(code: httpResponse.statusCode, html: dataString))
    }
  }
  return (false, HTTPResult.err("response is not of type HTTPURLResponse, data: \(dataString)"))
}
