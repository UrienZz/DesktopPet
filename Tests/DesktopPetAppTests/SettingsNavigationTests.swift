import Testing
@testable import DesktopPetApp

/// 验证设置侧边栏的显示顺序和标题。
@Test
func settingsSidebarOrderAndTitlesAreCorrect() {
    #expect(SettingsPane.allCases.map(\.title) == ["桌宠", "插件", "外观", "关于"])
}
