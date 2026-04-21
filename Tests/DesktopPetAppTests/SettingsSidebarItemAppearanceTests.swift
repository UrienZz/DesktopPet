import Testing
@testable import DesktopPetApp

@Test
func 设置侧边栏悬停态应强于默认态() {
    let idle = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: false, isPressed: false)
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)

    #expect(hovered.backgroundOpacity > idle.backgroundOpacity)
    #expect(hovered.borderOpacity > idle.borderOpacity)
    #expect(hovered.iconTileOpacity > idle.iconTileOpacity)
}

@Test
func 设置侧边栏选中态应强于悬停态() {
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let selected = SettingsSidebarItemAppearance.resolve(isSelected: true, isHovered: false, isPressed: false)

    #expect(selected.backgroundOpacity > hovered.backgroundOpacity)
    #expect(selected.indicatorOpacity > hovered.indicatorOpacity)
    #expect(selected.shadowOpacity > hovered.shadowOpacity)
}

@Test
func 设置侧边栏按压态应有轻微缩放() {
    let hovered = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let pressed = SettingsSidebarItemAppearance.resolve(isSelected: false, isHovered: true, isPressed: true)

    #expect(pressed.scale < hovered.scale)
    #expect(pressed.shadowOpacity < hovered.shadowOpacity)
}
