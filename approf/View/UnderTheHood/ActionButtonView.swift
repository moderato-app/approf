// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct ActionButtonView: View {
  @Bindable var store: StoreOf<DetailFeature>

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        HStack {
          UTHStatusView(store: store)
          actionButton()
        }
        DetectingHTTPView(store: store)
      }
      Spacer()
    }
  }

  @ViewBuilder
  private func actionButton() -> some View {
    switch store.period {
    case .idle, .terminated:
      Button("Launch") {
        store.send(.launchButtonTapped)
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case .failure:
      Button("Relaunch") {
        store.send(.launchButtonTapped)
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case let .success(su):
      HStack(alignment: .firstTextBaseline) {
        Button("Stop") {
          store.send(.stopButtonTapped)
        }
        if !store.basic.equalsSnapshot(su.snapshot) {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("Changes detected, ").foregroundStyle(.secondary)
            Button("reluanch") {
              store.send(.relaunchButtonTapped)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            Text("?").foregroundStyle(.secondary)
          }
        } else if store.showGoToWEB {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("Go to ").foregroundStyle(.secondary)
            Button("WEB") {
              store.send(.goToWEBButtonTapped)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            Text("?").foregroundStyle(.secondary)
          }
        }
      }
    case .launching:
      Button("Cancel") {
        store.send(.stopButtonTapped)
      }
    }
  }
}
