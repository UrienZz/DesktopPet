import SwiftUI
import WebKit

struct PluginWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        attach(webView, to: container)
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard webView.superview !== nsView else { return }
        attach(webView, to: nsView)
    }

    private func attach(_ webView: WKWebView, to container: NSView) {
        webView.removeFromSuperview()
        webView.translatesAutoresizingMaskIntoConstraints = false
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
}
