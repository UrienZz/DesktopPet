import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 关闭插件面板窗口时会触发关闭回调() {
    var didClose = false
    let window = PanelWindow(rootView: PluginEmptyStateView()) {
        didClose = true
    }

    window.close()

    #expect(didClose)
}
