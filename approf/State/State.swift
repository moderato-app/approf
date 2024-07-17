import Foundation

@Observable
class UIState {
  static var shared = UIState()
  var mouseInsideWindow = true
  private init() {}
}
