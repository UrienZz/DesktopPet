import Testing
@testable import DesktopPetApp

/// 验证设置侧边栏的显示顺序和标题。
@Test
func settingsSidebarOrderAndTitlesAreCorrect() {
    #expect(SettingsPane.allCases.map(\.title) == ["桌宠", "插件", "外观", "关于"])
}

/// 验证设置侧栏不再展示解释性副标题，保持系统设置式简洁导航。
@Test
func settingsSidebarDoesNotExposeExplanatorySubtitles() {
    #expect(SettingsPane.allCases.allSatisfy { $0.sidebarSubtitle == nil })
}

/// 验证设置侧栏采用参考图中的宽侧栏与大号导航项布局。
@Test
func settingsSidebarUsesReferenceImageLayoutMetrics() {
    #expect(SettingsSidebarLayout.width == 260)
    #expect(SettingsSidebarLayout.containerWidth == 284)
    #expect(SettingsSidebarLayout.outerPadding == 12)
    #expect(SettingsSidebarLayout.topPadding == 112)
    #expect(SettingsSidebarLayout.panelCornerRadius == 30)
    #expect(SettingsSidebarLayout.panelShadowRadius == 26)
    #expect(SettingsSidebarLayout.panelBackgroundOpacity == 0.36)
    #expect(SettingsSidebarLayout.panelShadowOpacity == 0.08)
    #expect(SettingsSidebarLayout.iconSize == 32)
    #expect(SettingsSidebarLayout.rowVerticalPadding == 12)
    #expect(SettingsSidebarLayout.titleFontSize == 16)
}
