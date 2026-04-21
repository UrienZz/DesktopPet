import AppKit
import WebKit

@MainActor
final class PluginWebViewCache {
    private final class NavigationDelegate: NSObject, WKNavigationDelegate {
        let pluginID: UUID
        var onLoadStart: (UUID) -> Void
        var onLoadFinish: (UUID, URL) -> Void
        var onLoadFail: (UUID) -> Void

        init(
            pluginID: UUID,
            onLoadStart: @escaping (UUID) -> Void,
            onLoadFinish: @escaping (UUID, URL) -> Void,
            onLoadFail: @escaping (UUID) -> Void
        ) {
            self.pluginID = pluginID
            self.onLoadStart = onLoadStart
            self.onLoadFinish = onLoadFinish
            self.onLoadFail = onLoadFail
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoadStart(pluginID)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadFinish(pluginID, webView.url ?? webView.backForwardList.currentItem?.url ?? aboutBlankURL)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            onLoadFail(pluginID)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            onLoadFail(pluginID)
        }

        private var aboutBlankURL: URL {
            URL(string: "about:blank")!
        }
    }

    private struct Entry {
        let webView: WKWebView
        let delegate: NavigationDelegate
        var requestedURL: URL
    }

    private var entries: [UUID: Entry] = [:]

    func reconcile(with plugins: [PluginConfiguration]) {
        let visiblePluginIDs = Set(plugins.filter(\.isEnabled).map(\.id))
        entries = entries.filter { visiblePluginIDs.contains($0.key) }
    }

    func webView(
        for plugin: PluginConfiguration,
        onLoadStart: @escaping (UUID) -> Void,
        onLoadFinish: @escaping (UUID, URL) -> Void,
        onLoadFail: @escaping (UUID) -> Void
    ) -> WKWebView {
        if var entry = entries[plugin.id] {
            entry.delegate.onLoadStart = onLoadStart
            entry.delegate.onLoadFinish = onLoadFinish
            entry.delegate.onLoadFail = onLoadFail

            if entry.requestedURL != plugin.url {
                entry.requestedURL = plugin.url
                entry.webView.load(URLRequest(url: plugin.url))
            }

            entries[plugin.id] = entry
            return entry.webView
        }

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true

        let delegate = NavigationDelegate(
            pluginID: plugin.id,
            onLoadStart: onLoadStart,
            onLoadFinish: onLoadFinish,
            onLoadFail: onLoadFail
        )
        webView.navigationDelegate = delegate
        webView.load(URLRequest(url: plugin.url))

        entries[plugin.id] = Entry(
            webView: webView,
            delegate: delegate,
            requestedURL: plugin.url
        )
        return webView
    }
}
