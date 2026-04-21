import Testing
@testable import DesktopPetApp

@Test
func 设置侧边栏顺序与标题正确() {
    #expect(SettingsPane.allCases.map(\.title) == ["桌宠", "插件", "外观", "关于"])
}
