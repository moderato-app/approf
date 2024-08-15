// Created for approf in 2024

import ComposableArchitecture
import Foundation
import Testing

@testable import approf

struct TestDropFiles2 {
  @Test
  @MainActor
  func testAppDropFiles() async throws {
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
    
    await store.send(.onAppear) {
      $0.synced = true
      $0.pprofsSelectedId = nil
    }
    
    let sharedBasic = PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false), urlB.path(percentEncoded: false)], createdAt: dg.now, presentation: .diff)
        
    await store.send(.drop(.onDropEnds([urlA, urlB]))) {
      $0.drop.destination = .uth(UnderTheHood.State(basic: Shared(sharedBasic)))
    }

    await store.send(\.drop.destination.uth.delegate.onConfirmImportButtonTapped) {
      $0.drop.destination = nil
    }

    await clock.advance(by: .seconds(1))

    var newBasic = sharedBasic
    newBasic.id = UUID(1)
    await store.receive(\.drop.delegate.addNewBasic){
      $0.basics = [newBasic]
      $0.pprofs = [DetailFeature.State(basic: Shared(newBasic), period: .idle(IdleFeature.State()))]
    }
    
    await store.receive(\.onPprofsSelectedIdChanged){
      $0.pprofsSelectedId = newBasic.id
    }
    
  }
}
