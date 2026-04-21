import AppKit

@MainActor
final class MenuBarController {
    private let statusItem: NSStatusItem

    init(
        onOpenSettings: @escaping () -> Void,
        onShowTrello: @escaping () -> Void,
        onResetPet: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cat.fill", accessibilityDescription: "Desktop Pet")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "打开设置", action: nil, keyEquivalent: "").onSelect(onOpenSettings)
        menu.addItem(withTitle: "打开 Trello", action: nil, keyEquivalent: "").onSelect(onShowTrello)
        menu.addItem(withTitle: "重置宠物位置", action: nil, keyEquivalent: "").onSelect(onResetPet)
        menu.addItem(.separator())
        menu.addItem(withTitle: "退出", action: nil, keyEquivalent: "q").onSelect(onQuit)
        statusItem.menu = menu
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
