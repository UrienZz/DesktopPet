import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 状态栏菜单应在重置位置上方显示暂停宠物动作() {
    let controller = MenuBarController(
        onOpenSettings: {},
        onShowTrello: {},
        onTogglePetAnimation: {},
        isPetAnimationPaused: false,
        onResetPet: {},
        onQuit: {}
    )

    #expect(controller.menuTitlesForTesting == ["打开设置", "打开 Trello", "暂停宠物动作", "重置宠物位置", "", "退出"])
}

@MainActor
@Test
func 状态栏菜单在暂停后应切换为开启宠物动作() {
    let controller = MenuBarController(
        onOpenSettings: {},
        onShowTrello: {},
        onTogglePetAnimation: {},
        isPetAnimationPaused: false,
        onResetPet: {},
        onQuit: {}
    )

    controller.updateAnimationMenu(isPaused: true)

    #expect(controller.animationMenuTitleForTesting == "开启宠物动作")
}
