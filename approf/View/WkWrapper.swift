import AppKit
import SwiftUI
import WebKit

struct WkWrapper: NSViewRepresentable {
  let wk: WKWebView
  @Bindable var wkState: WKState

  public func makeNSView(context: Context) -> WKWebView {
    wk.wantsLayer = true
    wk.navigationDelegate = context.coordinator
    wkState.url = wk.url
    return wk
  }

  func updateNSView(_ wk: WKWebView, context: Context) {
    wkState.url = wk.url
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WkWrapper

    init(_ parent: WkWrapper) {
      self.parent = parent
    }

    func webView(_ wk: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      parent.wkState.loading = true
    }

    func webView(_ wk: WKWebView, didFinish navigation: WKNavigation!) {
      parent.wkState.loading = false
      parent.wkState.url = wk.url
//      parent.wkState.updateStacks(with: webView)
    }

    func webView(_ wk: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      parent.wkState.loading = false
//      parent.wkState.updateStacks(with: webView)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
