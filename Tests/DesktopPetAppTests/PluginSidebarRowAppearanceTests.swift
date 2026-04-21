import Testing
@testable import DesktopPetApp

@Test
func 悬停态应比默认态更明显() {
    let idle = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: false, isPressed: false)
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)

    #expect(hovered.backgroundOpacity > idle.backgroundOpacity)
    #expect(hovered.borderOpacity > idle.borderOpacity)
    #expect(hovered.leadingIndicatorOpacity > idle.leadingIndicatorOpacity)
}

@Test
func 选中态应强于普通悬停态() {
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let selected = PluginSidebarRowAppearance.resolve(isSelected: true, isHovered: false, isPressed: false)

    #expect(selected.backgroundOpacity > hovered.backgroundOpacity)
    #expect(selected.leadingIndicatorOpacity > hovered.leadingIndicatorOpacity)
    #expect(selected.iconTileOpacity > hovered.iconTileOpacity)
}

@Test
func 按压态应产生轻微收缩反馈() {
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let pressed = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: true)

    #expect(pressed.scale < hovered.scale)
    #expect(pressed.shadowOpacity < hovered.shadowOpacity)
}
