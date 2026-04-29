import SwiftUI
import Testing
@testable import DesktopPetApp

/// 验证设置窗口内容延伸到标题栏下方，让侧栏材质覆盖窗口按钮区域。
@MainActor
@Test
func settingsWindowUsesFullSizeTransparentTitlebar() throws {
    let controller = SettingsWindowController(rootView: EmptyView(), onClose: {})
    let window = try #require(controller.window)

    #expect(window.styleMask.contains(.fullSizeContentView))
    #expect(window.titlebarAppearsTransparent)
}
