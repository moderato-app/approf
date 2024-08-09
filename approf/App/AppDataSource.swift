import ComposableArchitecture

struct DateSource{
  @MainActor
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
//      ._printChanges()
  }
}
