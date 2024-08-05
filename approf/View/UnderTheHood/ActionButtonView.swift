// Created for approf in 2024

import ComposableArchitecture
import SwiftUI

struct ActionButtonView: View {
  @Bindable var store: StoreOf<UnderTheHood>
  let periodStatus: PeroidStatus

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        HStack {
          UTHStatusView(periodStatus: periodStatus)
          actionButton()
        }
        DetectingHTTPView(basic: store.basic, periodStatus: periodStatus)
      }
      Spacer()
    }
  }

  @ViewBuilder
  private func actionButton() -> some View {
    switch periodStatus {
    case .idle, .terminated:
      Button("Launch") {
        store.send(.delegate(.launchButtonTapped))
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case .failure:
      Button("Relaunch") {
        store.send(.delegate(.launchButtonTapped))
      }
      .buttonStyle(BorderedProminentButtonStyle())
    case let .success(snapshot):
      HStack(alignment: .firstTextBaseline) {
        Button("Stop") {
          store.send(.delegate(.stopButtonTapped))
        }
        if store.basic.equalsSnapshot(snapshot: snapshot) {
          Button("go to web") {
            store.send(.delegate(.goToWEBButtonTapped))
          }
          .buttonStyle(.plain)
          .foregroundStyle(.tint)
          .fontDesign(.rounded)
        } else {
          Text("changes have been made, you may want to")
            .foregroundStyle(.secondary)
          Button("reluanch") {
            store.send(.delegate(.relaunchButtonTapped))
          }
          .buttonStyle(.plain)
          .foregroundStyle(.tint)
          .fontDesign(.rounded)
        }
      }
    case .launching:
      Button("Cancel") {
        store.send(.delegate(.stopButtonTapped))
      }
    }
  }
}
