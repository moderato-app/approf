// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct ShortcutsView: View {
  @Bindable var store: StoreOf<UnderTheHood>

  var body: some View {
    Rectangle()
      .fill(.clear)
      .frame(width: 1, height: 1)
      .allowsHitTesting(false)
      .sc(.upArrow, modifiers: [.command, .shift]) {
        store.send(.onMoveUpCommand, animation: .default)
      }
      .sc(.downArrow, modifiers: [.command, .shift]) {
        store.send(.onMoveDownCommand, animation: .default)
      }
      .sc(.rightArrow, modifiers: []) {
        store.send(.onNextPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: []) {
        store.send(.onNextPresentationCommand, animation: .default)
      }
      .sc(.leftArrow, modifiers: []) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: [.control]) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
      .sc(.tab, modifiers: [.shift]) {
        store.send(.onPrevPresentationCommand, animation: .default)
      }
  }
}
