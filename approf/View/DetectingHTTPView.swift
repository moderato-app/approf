import SwiftUI

struct DetectingHTTPView: View {
  let basic: PProfBasic
  let periodStatus: PeroidStatus

  var body: some View {
    switch periodStatus {
    case .launching:
      TringHttpView()
      HttpResultView(basic: basic)
    case .failure:
      HttpResultView(basic: basic)
    default:
      EmptyView()
    }
  }
}

struct TringHttpView: View {
  var body: some View {
    HStack {
      // bug: .rotate effect is not woking on macos 15 beta 3
      //          if #available(macOS 15.0, *) {
      //            Image(systemName: "circle.hexagonpath.fill")
      //              .symbolEffect(.rotate)
      //          }
      Spacer().frame(width: 5)
      ProgressView()
        .scaleEffect(0.5)
        .frame(width: 5, height: 5)
      Text("Trying HTTP request")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
}

struct HttpResultView: View {
  let basic: PProfBasic

  var body: some View {
    if let last = basic.httpDetectLog.last {
      HStack(alignment: .firstTextBaseline) {
        Text("HTTP result: ").foregroundStyle(.secondary)
        switch last {
        case let .err(str):
          Image("circle.fill").foregroundStyle(.red)
          Text(str).lineLimit(5)
        case let .http(code, html):
          Text("\(code)").foregroundStyle(code <= 299 && code >= 200 ? .green : .red)
          Text(html).lineLimit(5)
        }
      }
      .animation(.linear, value: last)
    }
  }
}
