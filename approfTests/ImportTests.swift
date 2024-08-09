//import ComposableArchitecture
//import Foundation
//import Testing
//
//@testable import approf
//
//@MainActor
//struct ImportTests {
//  let urlA = Bundle(for: Dummy.self).url(forResource: "a.pb", withExtension: "gz")!
//  let urlB = Bundle(for: Dummy.self).url(forResource: "b", withExtension: "pb")!
//
//  @Test("import 1 file")
//  func test1() async throws {
//
//    let store = TestStore(initialState: AppFeature.State()) {
//      AppFeature()
//    } withDependencies: {
//      $0.uuid = .incrementing
//    }
//
//    await store.send(.drop(.onDropEnds([urlA])))
////    
////    await send(.delegate(.addNewBasic(basic)), animation: .default)
////    try await clock.sleep(for: .seconds(0.1))
////    await send(.delegate(.selectPProf(basic.id)), animation: .default)
////
////    await store.receive(\.drop(.delegate(.addNewBasic))) {
////      XCTAssertEqual($0.basics.count, 1)
////    }
//
////    await store.send(.drop(.onDropEnds([urlA]))) {
////      $0.basics[id: UUID(0)] = PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false)])
////      $0.pprofs[id: UUID(0)] = .init(basic: Shared(PProfBasic(uuid: UUID(0), filePaths: [urlA.path(percentEncoded: false)])), period: .idle(IdleFeature.State()))
////      $0.synced = true
////    }
//  }
//
////  @Test("import 2 file")
////  func test2() async throws {
////    let store = TestStore(initialState: AppFeature.State()) {
////      AppFeature()
////    }
////
////
////    let basic = PProfBasic(filePaths: [pathA, pathB])
////    await store.send(.drop(.delegate(.addNewBasic(basic)))) {
////      $0.basics[id: basic.id] = basic
////      $0.pprofs[id: basic.id] = .init(basic: Shared(basic), period: .idle(IdleFeature.State()))
////      $0.synced = true
////    }
////  }
////
////  @Test("import 2 file for diff")
////  func test3() async throws {
////    let store = TestStore(initialState: AppFeature.State()) {
////      AppFeature()
////    }
////
////    let basic = PProfBasic(filePaths: [pathA, pathB], presentation: .dft)
////    await store.send(.drop(.delegate(.addNewBasic(basic)))) {
////      $0.basics[id: basic.id] = basic
////      $0.pprofs[id: basic.id] = .init(basic: Shared(basic), period: .idle(IdleFeature.State()))
////      $0.synced = true
////    }
////  }
//}
//
////    await store.send(\.path[id:0].detail.editButtonTapped) {
////      $0.path[id: 0]?.modify(\.detail) { $0.destination = .edit(SyncUpForm.State(syncUp: syncUp)) }
////    }
////
////    syncUp.title = "Blob"
////    await store.send(\.path[id:0].detail.destination.edit.binding.syncUp, syncUp) {
////      $0.path[id: 0]?.modify(\.detail) {
////        $0.destination?.modify(\.edit) { $0.syncUp.title = "Blob" }
////      }
////    }
////
////    await store.send(\.path[id:0].detail.doneEditingButtonTapped) {
////      $0.path[id: 0]?.modify(\.detail) {
////        $0.destination = nil
////        $0.syncUp.title = "Blob"
////      }
////    }
////    .finish()
////  }
////
////  @MainActor
////  func testDelete() async throws {
////    let syncUp = SyncUp.mock
////    @Shared(.syncUps) var syncUps = [syncUp]
////    let store = TestStore(initialState: AppFeature.State()) {
////      AppFeature()
////    }
////
////    let sharedSyncUp = try XCTUnwrap(Shared($syncUps[id: syncUp.id]))
////
////    await store.send(\.path.push, (id: 0, .detail(SyncUpDetail.State(syncUp: sharedSyncUp)))) {
////      $0.path[id: 0] = .detail(SyncUpDetail.State(syncUp: sharedSyncUp))
////    }
////
////    await store.send(\.path[id:0].detail.deleteButtonTapped) {
////      $0.path[id: 0]?.modify(\.detail) { $0.destination = .alert(.deleteSyncUp) }
////    }
////
////    await store.send(\.path[id:0].detail.destination.alert.confirmDeletion) {
////      $0.path[id: 0]?.modify(\.detail) { $0.destination = nil }
////      $0.syncUpsList.syncUps = []
////    }
////
////    await store.receive(\.path.popFrom) {
////      $0.path = StackState()
////    }
////  }
////
////  @MainActor
////  func testRecording() async {
////    let speechResult = SpeechRecognitionResult(
////      bestTranscription: Transcription(formattedString: "I completed the project"),
////      isFinal: true
////    )
////    let syncUp = SyncUp(
////      id: SyncUp.ID(),
////      attendees: [
////        Attendee(id: Attendee.ID()),
////        Attendee(id: Attendee.ID()),
////        Attendee(id: Attendee.ID()),
////      ],
////      duration: .seconds(6)
////    )
////
////    let sharedSyncUp = Shared(syncUp)
////    let store = TestStore(
////      initialState: AppFeature.State(
////        path: StackState([
////          .detail(SyncUpDetail.State(syncUp: sharedSyncUp)),
////          .record(RecordMeeting.State(syncUp: sharedSyncUp)),
////        ])
////      )
////    ) {
////      AppFeature()
////    } withDependencies: {
////      $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
////      $0.continuousClock = ImmediateClock()
////      $0.speechClient.authorizationStatus = { .authorized }
////      $0.speechClient.startTask = { @Sendable _ in
////        AsyncThrowingStream { continuation in
////          continuation.yield(speechResult)
////          continuation.finish()
////        }
////      }
////      $0.uuid = .incrementing
////    }
////    store.exhaustivity = .off
////
////    await store.send(\.path[id:1].record.onTask)
////    await store.receive(\.path.popFrom) {
////      XCTAssertEqual($0.path.count, 1)
////    }
////    store.assert {
////      $0.path[id: 0]?.modify(\.detail) {
////        $0.syncUp.meetings = [
////          Meeting(
////            id: Meeting.ID(UUID(0)),
////            date: Date(timeIntervalSince1970: 1_234_567_890),
////            transcript: "I completed the project"
////          )
////        ]
////      }
////    }
