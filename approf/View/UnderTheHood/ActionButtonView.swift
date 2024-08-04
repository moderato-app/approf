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
    case .success:
      HStack(alignment: .firstTextBaseline) {
        Button("Stop") {
          store.send(.delegate(.stopButtonTapped))
        }
        Button("go to web") {
          store.send(.delegate(.goToWEBButtonTapped))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .fontDesign(.rounded)
      }
    case .launching:
      Button("Cancel") {
        store.send(.delegate(.stopButtonTapped))
      }
    }
  }
}
