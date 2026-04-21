import AppKit

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem
    private let animationMenuItem = NSMenuItem()

    init(
        onOpenSettings: @escaping () -> Void,
        onTogglePetAnimation: @escaping () -> Void,
        isPetAnimationPaused: Bool,
        onResetPet: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cat.fill", accessibilityDescription: "Desktop Pet")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "打开设置", action: nil, keyEquivalent: "").onSelect(onOpenSettings)
        animationMenuItem.onSelect(onTogglePetAnimation)
        menu.addItem(animationMenuItem)
        menu.addItem(withTitle: "重置宠物位置", action: nil, keyEquivalent: "").onSelect(onResetPet)
        menu.addItem(.separator())
        menu.addItem(withTitle: "退出", action: nil, keyEquivalent: "q").onSelect(onQuit)
        statusItem.menu = menu
        updateAnimationMenu(isPaused: isPetAnimationPaused)
    }

    func updateAnimationMenu(isPaused: Bool) {
        animationMenuItem.title = Self.animationMenuTitle(isPaused: isPaused)
    }

    static func animationMenuTitle(isPaused: Bool) -> String {
        isPaused ? "开启宠物动作" : "暂停宠物动作"
    }

    var menuTitlesForTesting: [String] {
        statusItem.menu?.items.map(\.title) ?? []
    }

    var animationMenuTitleForTesting: String {
        animationMenuItem.title
    }
}

private final class MenuActionBox: NSObject {
    let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    @objc
    func performAction() {
        handler()
    }
}

private extension NSMenuItem {
    @discardableResult
    func onSelect(_ handler: @escaping () -> Void) -> NSMenuItem {
        let box = MenuActionBox(handler: handler)
        target = box
        action = #selector(MenuActionBox.performAction)
        representedObject = box
        return self
    }
}
