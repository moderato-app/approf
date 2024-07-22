import ComposableArchitecture
import Foundation

@Reducer
struct NotificationFeature {
  @ObservableState
  struct State: Equatable {
    var text: String
    var seconds: UInt?
  }

  enum Action {
    case onAppear
    case countDown
  }

  enum CancelID { case timer }
  @Dependency(\.continuousClock) var clock
  @Dependency(\.dismiss) var dismiss

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if let s = state.seconds {
          if s == 0 {
            fatalError("don't do this")
          }
          return .run { send in
            for await _ in self.clock.timer(interval: .seconds(1)) {
              await send(.countDown)
            }
          }.cancellable(id: CancelID.timer)
        } else {
          return .none
        }
      case .countDown:
        state.seconds? -= 1
        if state.seconds == 0 {
          return .merge(
            .cancel(id: CancelID.timer),
            .run { _ in await dismiss() }
          )
        }
        return .none
      }
    }
  }
}
