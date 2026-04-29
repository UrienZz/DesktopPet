import AppKit
import WebKit

@MainActor
final class PluginWebViewCache {
    private final class NavigationDelegate: NSObject, WKNavigationDelegate {
        let pluginID: UUID
        var requestedURL: URL
        var onLoadStart: (UUID) -> Void
        var onLoadCommit: (UUID, URL) -> Void
        var onLoadFinish: (UUID, URL) -> Void
        var onLoadFail: (UUID) -> Void

        init(
            pluginID: UUID,
            requestedURL: URL,
            onLoadStart: @escaping (UUID) -> Void,
            onLoadCommit: @escaping (UUID, URL) -> Void,
            onLoadFinish: @escaping (UUID, URL) -> Void,
            onLoadFail: @escaping (UUID) -> Void
        ) {
            self.pluginID = pluginID
            self.requestedURL = requestedURL
            self.onLoadStart = onLoadStart
            self.onLoadCommit = onLoadCommit
            self.onLoadFinish = onLoadFinish
            self.onLoadFail = onLoadFail
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            onLoadStart(pluginID)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            onLoadCommit(pluginID, requestedURL)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadFinish(pluginID, requestedURL)
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
    }

    private final class UIDelegate: NSObject, WKUIDelegate {
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard navigationAction.targetFrame?.isMainFrame != true else {
                return nil
            }

            webView.load(navigationAction.request)
            return nil
        }
    }

    private struct Entry {
        let webView: WKWebView
        let delegate: NavigationDelegate
        let uiDelegate: UIDelegate
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
        onLoadCommit: @escaping (UUID, URL) -> Void,
        onLoadFinish: @escaping (UUID, URL) -> Void,
        onLoadFail: @escaping (UUID) -> Void
    ) -> WKWebView {
        if var entry = entries[plugin.id] {
            entry.delegate.requestedURL = plugin.url
            entry.delegate.onLoadStart = onLoadStart
            entry.delegate.onLoadCommit = onLoadCommit
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
            requestedURL: plugin.url,
            onLoadStart: onLoadStart,
            onLoadCommit: onLoadCommit,
            onLoadFinish: onLoadFinish,
            onLoadFail: onLoadFail
        )
        let uiDelegate = UIDelegate()
        webView.navigationDelegate = delegate
        webView.uiDelegate = uiDelegate
        webView.load(URLRequest(url: plugin.url))

        entries[plugin.id] = Entry(
            webView: webView,
            delegate: delegate,
            uiDelegate: uiDelegate,
            requestedURL: plugin.url
        )
        return webView
    }
}
