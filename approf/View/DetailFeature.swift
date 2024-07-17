import ComposableArchitecture
import Foundation
import WebKit

@Reducer
struct DetailFeature {
  @ObservableState
  struct State: Equatable, Identifiable {
    var id: UUID
    @Shared var basic: PProfBasic
    var period: PProfPeriod.State
    var subViewType: DetailSubViewType
    var uth: UnderTheHood.State

    init(basic: Shared<PProfBasic>, period: PProfPeriod.State) {
      self.id = basic.id
      _basic = basic
      self.period = period
      self.subViewType = .underTheHood
      self.uth = UnderTheHood.State(basic: basic)
    }
  }

  enum Action {
    case period(PProfPeriod.Action)
    case uth(UnderTheHood.Action)
    case onAppear
    case onSwitchViewButtonTapped
  }

  enum CancelID { case timer }

  var body: some ReducerOf<Self> {
    Scope(state: \.uth, action: \.uth) {
      UnderTheHood()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        if case .idle = state.period {
          state.period = .launching(LaunchingFeature.State(basic: state.$basic))
          return .send(.period(.launching(.start)))
        }
        return .none
      case .onSwitchViewButtonTapped:
        state.subViewType = state.subViewType.switchView()
        return .none
      case .uth(.delegate(.launchButtonTapped)),
           .period(.failure(.delegate(.launchButtonTapped))),
           .period(.idle(.delegate(.launchButtonTapped))),
           .period(.terminated(.delegate(.launchButtonTapped))):
        self.cleanUp(state: &state)
        state.period = .launching(LaunchingFeature.State(basic: state.$basic))
        return .send(.period(.launching(.start)))
      case let .period(.launching(.delegate(.onSuccess(process, portReady)))):
        let conf = WKWebViewConfiguration()
        conf.defaultWebpagePreferences.allowsContentJavaScript = true
        conf.allowsAirPlayForMediaPlayback = false
        conf.preferences.setValue(true, forKey: "developerExtrasEnabled")

        let wk = WKWebView(frame: .zero, configuration: conf)
        wk.layer?.borderWidth = 0
        state.period = .success(.init(basic: state.$basic, process: process, port: portReady, wk: wk))
        state.subViewType = .graphic
        return .merge(
          .run { _ in
            await wk.load(URLRequest(url: URL(string: "http://localhost:\(portReady)")!))
          },
          .run { send in
            try await Task.sleep(for: .seconds(0.3))
            await send(.period(.success(.onFullyLoaded)), animation: .default)
          }
        )
      case let .period(.launching(.delegate(.onFailed(cause)))):
        state.period = .failure(.init(basic: state.$basic, cause: cause))
        return .none
      case .uth(.delegate(.stopButtonTapped)):
        return .merge(
          .send(.period(.launching(.stop))),
          .send(.period(.success(.stop)))
        )
      case .period(.launching(.delegate(.onTermimated))),
           .period(.success(.delegate(.onTermimated))):
        state.period = .terminated(.init())
        return .none
      case .period:
        return .none
      case .uth:
        return .none
      }
    }
    .ifLet(\.period.idle, action: \.period.idle) {
      IdleFeature()
    }
    .ifLet(\.period.terminated, action: \.period.terminated) {
      IdleFeature()
    }
    .ifLet(\.period.launching, action: \.period.launching) {
      LaunchingFeature()
    }
    .ifLet(\.period.success, action: \.period.success) {
      SuccessFeature()
    }
    .ifLet(\.period.failure, action: \.period.failure) {
      FailureFeature()
    }
  }

  func cleanUp(state: inout Self.State) {
    state.basic.terminalOutput = []
    state.basic.httpDetectLog = []
    state.basic.finalCommandArgs = []
  }
}

extension DetailFeature {
  @Reducer(state: .equatable)
  enum PProfPeriod {
    case idle(IdleFeature)
    case terminated(IdleFeature)
    case launching(LaunchingFeature)
    case failure(FailureFeature)
    case success(SuccessFeature)

    func isRunning() -> Bool {
      if case .launching = self {
        return true
      } else {
        return false
      }
    }
  }
}

extension DetailFeature.State {
  var isRunning: Bool {
    if case .success = self.period {
      return true
    } else {
      return false
    }
  }

  var periodStatus: PeroidStatus {
    switch self.period {
    case .idle:
      .idle
    case .terminated:
      .terminated
    case .launching:
      .launching
    case .failure:
      .failure
    case .success:
      .success
    }
  }
}

extension DetailFeature.State {
  enum DetailSubViewType: Codable, CaseIterable {
    case underTheHood, graphic

    func switchView() -> Self {
      switch self {
      case .underTheHood:
        .graphic
      case .graphic:
        .underTheHood
      }
    }

    var systemImage: String {
      switch self {
      case .underTheHood:
        "apple.terminal.fill"
      case .graphic:
        "apple.terminal"
      }
    }

    var help: String {
      switch self {
      case .underTheHood:
        "Toggle WEB view"
      case .graphic:
        "See what's under the hood"
      }
    }
  }
}
