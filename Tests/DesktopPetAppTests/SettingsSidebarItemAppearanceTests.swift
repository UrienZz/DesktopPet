import Testing
@testable import DesktopPetApp

/// 验证设置侧边栏悬停态优先于默认态。
@Test
func settingsSidebarHoverStateOverridesDefaultState() {
    let idle = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: false, isPressed: false)
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)

    #expect(hovered.backgroundOpacity > idle.backgroundOpacity)
    #expect(hovered.borderOpacity > idle.borderOpacity)
    #expect(hovered.iconTileOpacity > idle.iconTileOpacity)
}

/// 验证设置侧边栏选中态优先于悬停态。
@Test
func settingsSidebarSelectedStateOverridesHoverState() {
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let selected = SettingsSidebarItemAppearance.resolve(isSelected: true, isHovered: false, isPressed: false)

    #expect(selected.backgroundOpacity > hovered.backgroundOpacity)
    #expect(selected.indicatorOpacity > hovered.indicatorOpacity)
    #expect(selected.shadowOpacity > hovered.shadowOpacity)
}

/// 验证设置侧边栏按压态会产生轻微缩放。
@Test
func settingsSidebarPressedStateAppliesSlightScale() {
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let pressed = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: true)

    #expect(pressed.scale < hovered.scale)
    #expect(pressed.shadowOpacity < hovered.shadowOpacity)
}
