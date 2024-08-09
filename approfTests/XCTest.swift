// Created for approf in 2024

import ComposableArchitecture
import XCTest

@testable import approf

final class AppFeatureTests: XCTestCase {
  
  @MainActor
  func testDetailEdit() async throws {
    let urlA = Bundle(for: Dummy.self).url(forResource: "a.pb", withExtension: "gz")!
    let urlB = Bundle(for: Dummy.self).url(forResource: "b", withExtension: "pb")!
    let clock = TestClock()

//    let store = TestStore(initialState: AppFeature.State()) {
//      AppFeature()
//    } withDependencies: {
//      $0.uuid = .incrementing
////      $0.continuousClock = clock
//    }
    
    let dropStore = TestStore(initialState: DropFeature.State()) {
      DropFeature()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.continuousClock = clock
    }

//    await store.send(.onAppear) {
//      $0.synced = true
//    }
//
//    await store.send(.drop(.onDropEnds([urlA]))) {
//      $0.basics[id: UUID(0)] = PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false)])
//      $0.pprofs[id: UUID(0)] = .init(basic: Shared(PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false)])), period: .idle(IdleFeature.State()))
//      $0.synced = true
//    }

    await dropStore.send(.onCursorEnter){
      $0.dropping = true
    }

    await dropStore.send(.onCursorLeave){
      $0.dropping = false
    }

    await dropStore.send(.onCursorEnter){
      $0.dropping = true
    }

    var sharedBasic = PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false), urlB.path(percentEncoded: false)], presentation: .diff)
    await dropStore.send(.onDropEnds([urlA, urlB])){
      $0.destination = .uth(UnderTheHood.State(basic: Shared(sharedBasic)))
    }
//    await dropStore.send(.onDropEnds([urlA, urlB])){
//      $0.dropping
//    }

//    await send(.delegate(.addNewBasic(basic)), animation: .default)
//    try await clock.sleep(for: .seconds(0.1))
//    await send(.delegate(.selectPProf(basic.id)), animation: .default)
    await clock.advance(by: .seconds(1))

//    await dropStore.receive(\.drop.delegate.addNewBasic) {
//      XCTAssertEqual($0.basics.count, 1)
//    }
//    await store.receive(\.drop.delegate.addNewBasic) {
//      XCTAssertEqual($0.basics.count, 1)
//    }
  }
}
