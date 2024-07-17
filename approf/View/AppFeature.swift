import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var synced = false // whether pprofs is synced with basics
    @Shared(.approf) var basics: IdentifiedArrayOf<PProfBasic> = .init(uniqueElements: [])
    var pprofs: IdentifiedArrayOf<DetailFeature.State> = .init()
    var pprofsSelectedId: UUID?

    var drop: DropFeature.State = .init()
  }

  enum Action {
    case onAppear
    case onPprofsSelectedIdChanged(UUID?)
    case onAppTermination
    case deleteButtonTapped(UUID)
    case onDeleteCommand
    case deleteNow(UUID)
    case pprofs(IdentifiedActionOf<DetailFeature>)

    case onCloseTabCommand

    case drop(DropFeature.Action)
  }

  @Dependency(\.uuid) var uuid

  var body: some ReducerOf<Self> {
    Scope(state: \.drop, action: \.drop) {
      DropFeature()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        self.sync(&state)
        return .none
      case let .onPprofsSelectedIdChanged(uuidOpt):
        state.pprofsSelectedId = uuidOpt
        return .none
      case let .deleteButtonTapped(id):
        if let pprof = state.pprofs.first(where: { $0.id == id }) {
          state.basics.removeAll(where: { $0.id == pprof.basic.id })
          switch pprof.period {
          case let .launching(la):
            if let process = la.process {
              if process.isRunning {
                process.terminate()
              }
            }
          case let .success(su):
            if su.process.isRunning {
              su.process.terminate()
            }
          default:
            let _ = 1
          }
          return .run { send in
            await send(.pprofs(.element(id: pprof.id, action: .period(.launching(.stop)))))
            await send(.pprofs(.element(id: pprof.id, action: .period(.success(.stop)))))
            await send(.deleteNow(id))
          }
        }
        log.warning("onDeleteTapped: pprof does not exist, id: \(id)")
        return .none
      case .onDeleteCommand:
        if let id = state.pprofsSelectedId {
          return .send(.deleteButtonTapped(id))
        }
        return .none
      case let .deleteNow(id):
        delete(&state, id)
        return .none
      case .onAppTermination:
        terminateAllProcesses(state: &state)
        return .none
      case .onCloseTabCommand:
        state.pprofsSelectedId = nil
        return .none
      case .pprofs:
        return .none
      case let .drop(.delegate(.addNewBasic(basic))):
        self.addNewBasic(&state, basic)
        return .none
      case let .drop(.delegate(.selectPProf(uuid))):
        if state.pprofs.contains(where: { $0.id == uuid }) {
          state.pprofsSelectedId = uuid
        }
        return .none
      case .drop:
        return .none
      }
    }
    .forEach(\.pprofs, action: \.pprofs) {
      DetailFeature()
    }
  }

  func addNewBasic(_ state: inout Self.State, _ basic: PProfBasic) {
    state.basics.insert(basic, at: 0)
    state.synced = false
    sync(&state)
  }

  func sync(_ state: inout Self.State) {
    if !state.synced {
      for basic in state.$basics.elements {
        let pprofIds = state.pprofs.ids
        if !pprofIds.contains(basic.id) {
          let pprof = DetailFeature.State(basic: basic, period: .idle(.init()))
          state.pprofs.insert(pprof, at: 0)
        }
      }
      state.synced = true
    }
  }

  func terminateAllProcesses(state: inout Self.State) {
    for pprof in state.pprofs {
      if case let .launching(l) = pprof.period, let process = l.process, process.isRunning {
        let pid = process.processIdentifier
        log.info("terminating process [pid=\(pid)]")
        process.terminate()
      } else if case let .success(s) = pprof.period, s.process.isRunning {
        let pid = s.process.processIdentifier
        log.info("terminating process [pid=\(pid)]")
        s.process.terminate()
      }
    }
  }

  /// Remove an element and update the selection accordingly
  private func delete(_ state: inout Self.State, _ id: UUID) {
    // Remember the selection index before deleting an element
    var originalIndex: Int?
    if let selection = state.pprofsSelectedId {
      originalIndex = state.pprofs.firstIndex { $0.id == selection }
    }

    state.pprofs.removeAll { $0.id == id }

    if let selection = state.pprofsSelectedId {
      // If the selected element is deleted
      if !state.pprofs.contains(where: { $0.id == selection }), let originalIndex = originalIndex {
        if originalIndex < state.pprofs.count {
          // If there were elements after it, select the next one
          state.pprofsSelectedId = state.pprofs[originalIndex].id
        } else {
          // Otherwise(selection was the last element), select the last element in the list
          state.pprofsSelectedId = state.pprofs.last?.id
        }
      }
    }
  }
}

extension PersistenceReaderKey
  where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<PProfBasic>>>
{
  static var approf: Self {
    PersistenceKeyDefault(
      .fileStorage(.homeDirectory.appending(component: ".approf.json")),
      []
    )
  }
}