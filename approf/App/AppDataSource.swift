import ComposableArchitecture

struct DateSource{
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
//      ._printChanges()
  }
}
