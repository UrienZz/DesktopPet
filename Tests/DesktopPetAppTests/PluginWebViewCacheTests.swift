import Testing
import WebKit
@testable import DesktopPetApp

/// 验证插件 WebView 会保留 UI delegate，以处理 Google 登录等 OAuth 新窗口请求。
@MainActor
@Test
func pluginWebViewRetainsUIDelegateForPopupNavigation() {
    let cache = PluginWebViewCache()
    let plugin = PluginConfiguration(
        id: UUID(),
        name: "Trello",
        url: URL(string: "https://trello.com")!,
        iconName: "tray.fill",
        isEnabled: true,
        sortOrder: 0
    )

    let webView = cache.webView(
        for: plugin,
        onLoadStart: { _ in },
        onLoadCommit: { _, _ in },
        onLoadFinish: { _, _ in },
        onLoadFail: { _ in }
    )

    #expect(webView.uiDelegate != nil)
}
