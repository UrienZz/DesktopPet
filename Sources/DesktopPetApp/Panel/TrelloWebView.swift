import SwiftUI
import WebKit

struct TrelloWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: AppConstants.trelloBoardURL))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
}
