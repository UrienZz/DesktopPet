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
