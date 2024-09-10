import ComposableArchitecture
import Foundation

@Reducer
struct LaunchingFeature {
  @ObservableState
  struct State: Equatable {
    @Shared var basic: PProfBasic
    var process: Process?
    var readingTerminal = false
    var portReady: UInt16?
    var detectingHttp = false
    var httpReady = false
    
    var goToWebOnSuccess = false
  }
  
  enum Action {
    case start
    case stop
    case launchingTimeout(Int)
    case readTerminal(AsyncStream<String>)
    case portReady(UInt16)
    case tryHttp(UInt16)
    case httpReady
    case fail(FailureFeature.Cause)
    case terminalUpdated(String)
    case httpUpdated(HTTPResult)
    case delegate(Delegate)
    
    @CasePathable
    enum Delegate: Equatable {
      case onSuccess(Process, UInt16, Bool) // goToWEB: Bool
      case onFailed(FailureFeature.Cause)
      case onTermimated
    }
  }
  
  enum CancelID { case terminalReader, httpDetector }
  @Dependency(\.continuousClock) var clock
  @Dependency(\.date) var date
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
      case .start:
        if let p = state.process {
          log.error("process already exeists")
          return .send(.fail(.process("process already exeists. process.processIdentifier: \(p.processIdentifier)")))
        }
        
        state.basic.terminalOutput = []
        state.basic.httpDetectLog = []
              
        var processOptional: Process?
        var streamOptional: AsyncStream<String>?
        do {
          let args = state.basic.commandArgs()
          let (commandArgs, process, terminalStream) = try createPProfProcess(args)
          state.process = process
          state.basic.finalCommandArgs = commandArgs
          processOptional = process
          streamOptional = terminalStream
        } catch {
          return .send(.fail(.process(error.localizedDescription)))
        }
        
        let process = processOptional!
        let stream = streamOptional!
        
        return .run { send in
          do {
            try process.run()
            log.info("process.isRunning: \(process.isRunning), process.processIdentifier.: \(process.processIdentifier)")
            if !process.isRunning {
              log.error("process.terminationStatus: \(process.terminationStatus), process.terminationReason: \(process.terminationReason)")
            }
          } catch {
            return await send(.fail(.process(error.localizedDescription)))
          }
          await send(.readTerminal(stream))
          await send(.launchingTimeout(5))
        }
      case .stop:
        if let process = state.process {
          if process.isRunning {
            process.terminate()
          }
          state.process = nil
        }
        return .send(.delegate(.onTermimated))
      case let .readTerminal(stream):
        state.readingTerminal.toggle()
        if state.readingTerminal {
          return .run { send in
            for try await data in stream {
              log.debug("read from stream: \(data)")
              await send(.terminalUpdated(data))
            }
            log.debug("finished reading from stream")
          }
          .cancellable(id: CancelID.terminalReader)
        } else {
          return .cancel(id: CancelID.terminalReader)
        }
      case let .portReady(port):
        state.portReady = port
        return .send(.tryHttp(port))
      case let .tryHttp(port):
        state.detectingHttp.toggle()
        if state.detectingHttp {
          let httpAddr = "http://localhost:\(port)"
          guard let httpUrl = URL(string: httpAddr) else {
            let e = "can't make a URL from \(httpAddr)"
            log.error("\(e)")
            return .none
          }
          
          return .run { send in
            
            let (ok, httpResult) = await detectHttpOk2(httpUrl: httpUrl, bodyShouldContain: "<h1><a href=\"./\">pprof</a></h1>")
            if ok {
              return await send(.httpReady)
            } else {
              await send(.httpUpdated(httpResult))
            }
            
            for await _ in self.clock.timer(interval: .seconds(1)) {
              let (ok, httpResult) = await detectHttpOk2(httpUrl: httpUrl, bodyShouldContain: "<h1><a href=\"./\">pprof</a></h1>")
              if ok {
                return await send(.httpReady)
              } else {
                await send(.httpUpdated(httpResult))
              }
            }
          }
          .cancellable(id: CancelID.httpDetector)
        } else {
          return .cancel(id: CancelID.httpDetector)
        }
      case let .terminalUpdated(text):
        state.basic.terminalOutput.append(.init(date: date.now, std: .out, text: text))
        if let port = state.basic.terminalOutput.map({ $0.text }).joined().extractPort() {
          state.portReady = port
          return .send(.portReady(port))
        }
        return .none
      case let .httpUpdated(HTTPResult):
        state.basic.httpDetectLog.append(HTTPResult)
        return .none
      case .httpReady:
        if let process = state.process, let port = state.portReady {
          return .send(.delegate(.onSuccess(process, port, state.goToWebOnSuccess)))
        } else {
          return .send(.fail(.process("failed: let process = state.process, let port = state.portReady")))
        }
      case let .launchingTimeout(timeout):
        if timeout > 0 {
          return .run { send in
            try await self.clock.sleep(for: .seconds(timeout))
            await send(.launchingTimeout(0))
          }
        }
        
        if state.portReady == nil || !state.httpReady || state.process?.isRunning ?? false {
          return .send(.fail(.process("launch timeout")))
        }
        return .none
      case let .fail(cause):
        state.process?.terminate()
        return .send(.delegate(.onFailed(cause)))
      }
    }
  }
}

extension LaunchingFeature.State {}

enum HTTPResult: Equatable {
  case http(code: Int, html: String), err(String)
}
