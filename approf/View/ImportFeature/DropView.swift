import Combine
import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct DropView: View {
  @Bindable var store: StoreOf<DropFeature>

  @State var viewSize = CGSize(width: 800, height: 600)
  var body: some View {
    Rectangle()
      .fill(.clear)
      .onGeometryChange(for: CGSize.self) { proxy in
        proxy.size
      } action: { viewSize = $0 }
      .allowsHitTesting(false)
      .overlay {
        if store.dropping {
          GradientBackgroundAnimation()
            .ignoresSafeArea()
        }
      }
      .onDrop(of: profTypes, delegate: DropFileDelegate(store: store))
      .sheet(
        item: $store.scope(state: \.destination?.importing, action: \.destination.importing)
      ) { importingStore in
        ImportView(store: importingStore)
          .frame(width: viewSize.width * 0.7, height: viewSize.height * 0.8)
          .presentationCornerRadius(20)
          .presentationBackgroundInteraction(.disabled)
      }
  }
}

class DropFileDelegate: DropDelegate {
  @Bindable var store: StoreOf<DropFeature>
  private var cancellables = Set<AnyCancellable>()

  init(store: StoreOf<DropFeature>) {
    self.store = store
  }

  func validateDrop(info: DropInfo) -> Bool {
    if case .importing = store.destination {
      return false
    }
    return true
  }

  func dropEntered(info: DropInfo) {
    store.send(.onCursorEnter, animation: .default)
  }

//    func dropUpdated(info: DropInfo) -> DropProposal? {}

  func dropExited(info: DropInfo) {
    store.send(.onCursorLeave, animation: .default)
  }

  func performDrop(info: DropInfo) -> Bool {
    let providers = info.itemProviders(for: profTypes)
    let futureArray = providers.compactMap { provider in
      profTypes.compactMap { ptype in
        if provider.hasItemConformingToTypeIdentifier(ptype.identifier) {
          return Future<URL?, Never> { promise in
            _ = provider.loadFileRepresentation(for: ptype, openInPlace: true) { url, _, error in
              if let error = error {
                print("Error loading file representation: \(error)")
                promise(.success(nil))
                return
              }
              promise(.success(url))
            }
          }
        }
        return nil
      }
    }.flatMap { $0 }

    if futureArray.isEmpty {
      return true
    }

    Publishers.MergeMany(futureArray)
      .collect()
      .receive(on: DispatchQueue.main)
      .sink { result in
        let urls = result.compactMap { $0 } as [URL]
        log.info("imported \(urls.count) files")
        Task { @MainActor in
          self.store.send(.onDropEnds(urls))
        }
      }
      .store(in: &cancellables)

    return true
  }
}
