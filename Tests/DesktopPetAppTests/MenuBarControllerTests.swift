import Testing
@testable import DesktopPetApp

/// 验证状态栏菜单会在重置位置上方显示暂停宠物动作。
@MainActor
@Test
func statusMenuShowsPauseAnimationAboveResetPosition() {
    let controller = MenuBarController(
        onOpenSettings: {},
        onTogglePetAnimation: {},
        isPetAnimationPaused: false,
        onResetPet: {},
        onQuit: {}
    )

    #expect(controller.menuTitlesForTesting == ["打开设置", "暂停宠物动作", "重置宠物位置", "", "退出"])
}

/// 验证状态栏菜单在暂停后会切换为开启宠物动作。
@MainActor
@Test
func statusMenuTitleSwitchesToResumeAnimationAfterPause() {
    let controller = MenuBarController(
        onOpenSettings: {},
        onTogglePetAnimation: {},
        isPetAnimationPaused: false,
        onResetPet: {},
        onQuit: {}
    )

    controller.updateAnimationMenu(isPaused: true)

    #expect(controller.animationMenuTitleForTesting == "开启宠物动作")
}
