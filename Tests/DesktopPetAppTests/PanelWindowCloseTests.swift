import Testing
@testable import DesktopPetApp

/// 验证关闭插件面板窗口时会触发关闭回调。
@MainActor
@Test
func closingPluginPanelWindowTriggersCloseCallback() {
    var didClose = false
    let window = PanelWindow(rootView: PluginEmptyStateView()) {
        didClose = true
    }

    window.close()

    #expect(didClose)
}

/// 验证插件面板具备浏览器式交互窗口语义，支持复杂网页拖拽。
@MainActor
@Test
func pluginPanelWindowSupportsBrowserLikePointerInteractions() {
    let window = PanelWindow(rootView: PluginEmptyStateView())

    #expect(window.canBecomeKey)
    #expect(window.canBecomeMain)
    #expect(window.acceptsMouseMovedEvents)
}
