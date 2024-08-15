// Created for approf in 2024

import ComposableArchitecture
import XCTest

@testable import approf

final class TestDropFilesLegacy: XCTestCase {
  @MainActor
  func testDropFiles() async throws {
    let urlA = Bundle(for: Dummy.self).url(forResource: "a.pb", withExtension: "gz")!
    let urlB = Bundle(for: Dummy.self).url(forResource: "b", withExtension: "pb")!
    
    let clock = TestClock()
    let dg = DateGenerator.constant(.distantPast)
    
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.continuousClock = clock
      $0.date = dg
    }

    let dropStore = TestStore(initialState: DropFeature.State()) {
      DropFeature()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.continuousClock = clock
      $0.date = dg
    }

    await store.send(.onAppear) {
      $0.synced = true
    }

    await dropStore.send(.onCursorEnter) {
      $0.dropping = true
    }

    await dropStore.send(.onCursorLeave) {
      $0.dropping = false
    }

    await dropStore.send(.onCursorEnter) {
      $0.dropping = true
    }
    let sharedBasic = PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false), urlB.path(percentEncoded: false)], createdAt: dg.now, presentation: .diff)

    await clock.advance(by: .seconds(1))
    await dropStore.send(.onDropEnds([urlA, urlB])) {
      $0.destination = .uth(UnderTheHood.State(basic: Shared(sharedBasic)))
    }
    
    await store.send(.drop(.onDropEnds([urlA, urlB]))) {
      $0.drop.destination = .uth(UnderTheHood.State(basic: Shared(sharedBasic)))
    }
  }
}
