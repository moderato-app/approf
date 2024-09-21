import Combine
import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct DropAndImportView: View {
  @Bindable var store: StoreOf<DropAndImportFeature>

  @State var viewSize = CGSize(width: 800, height: 600)
  @State var dropping = false
  @State var uiState = UIState.shared

  var body: some View {
    Rectangle()
      .fill(.clear)
      .onGeometryChange(for: CGSize.self) { proxy in
        proxy.size
      } action: { viewSize = $0 }
      .allowsHitTesting(false)
      .overlay {
        if dropping && store.destination == nil {
          GradientBackgroundAnimation()
        }
      }
      .animation(.default, value: dropping)
      .onDrop(of: allowedImportFileTypes, delegate: DropFileDelegate(dropping: $dropping) { urls in
        if store.destination == nil{
          store.send(.onDropEnds(urls))
        }
      })
      .sheet(
        item: $store.scope(state: \.destination?.uth, action: \.destination.uth)
      ) { importingStore in
        ImportView(store: importingStore)
          .padding(20)
          .frame(width: viewSize.width * 0.7, height: viewSize.height * 0.8)
          .presentationCornerRadius(20)
          .presentationBackgroundInteraction(.disabled)
      }
  }
}

class DropFileDelegate: DropDelegate {
  @Binding var dropping: Bool
  let onDropEnds: ([URL]) -> Void
  let excludeArea: CGRect?

  private var cancellables = Set<AnyCancellable>()

  init(dropping: Binding<Bool>, excludeArea: CGRect? = nil, onDropEnds: @escaping ([URL]) -> Void) {
    _dropping = dropping
    self.excludeArea = excludeArea
    self.onDropEnds = onDropEnds
  }

  func validateDrop(info: DropInfo) -> Bool {
    return true
  }

  func dropEntered(info: DropInfo) {
    if let excludeArea = excludeArea, excludeArea.contains(info.location) {
      dropping = false
    } else {
      dropping = true
    }
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    dropEntered(info: info)
    return nil
  }

  func dropExited(info: DropInfo) {
    dropping = false
  }

  func performDrop(info: DropInfo) -> Bool {
    let providers = info.itemProviders(for: allowedImportFileTypes)
    let futureArray = providers.compactMap { provider in
      allowedImportFileTypes.compactMap { ptype in
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
          self.onDropEnds(urls)
        }
      }
      .store(in: &cancellables)
    return true
  }
}
