import Testing
@testable import DesktopPetApp

/// 验证悬停态比默认态更明显。
@Test
func hoverStateIsMoreProminentThanDefaultState() {
    let idle = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: false, isPressed: false)
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)

    #expect(hovered.backgroundOpacity > idle.backgroundOpacity)
    #expect(hovered.borderOpacity > idle.borderOpacity)
    #expect(hovered.leadingIndicatorOpacity > idle.leadingIndicatorOpacity)
}

/// 验证选中态强于普通悬停态。
@Test
func selectedStateOverridesNormalHoverState() {
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let selected = PluginSidebarRowAppearance.resolve(isSelected: true, isHovered: false, isPressed: false)

    #expect(selected.backgroundOpacity > hovered.backgroundOpacity)
    #expect(selected.leadingIndicatorOpacity > hovered.leadingIndicatorOpacity)
    #expect(selected.iconTileOpacity > hovered.iconTileOpacity)
}

/// 验证按压态会产生轻微收缩反馈。
@Test
func pressedStateAppliesSlightShrinkFeedback() {
    let hovered = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: false)
    let pressed = PluginSidebarRowAppearance.resolve(isSelected: false, isHovered: true, isPressed: true)

    #expect(pressed.scale < hovered.scale)
    #expect(pressed.shadowOpacity < hovered.shadowOpacity)
}
