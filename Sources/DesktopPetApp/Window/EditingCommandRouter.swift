import AppKit

@MainActor
enum EditingCommandRouter {
    static func action(
        forKeyEquivalent keyEquivalent: String,
        modifiers: NSEvent.ModifierFlags
    ) -> Selector? {
        let normalizedModifiers = modifiers.intersection(.deviceIndependentFlagsMask)
        let normalizedKey = keyEquivalent.lowercased()

        switch (normalizedModifiers, normalizedKey) {
        case ([.command], "a"):
            return NSSelectorFromString("selectAll:")
        case ([.command], "c"):
            return NSSelectorFromString("copy:")
        case ([.command], "v"):
            return NSSelectorFromString("paste:")
        case ([.command], "x"):
            return NSSelectorFromString("cut:")
        case ([.command], "z"):
            return NSSelectorFromString("undo:")
        case ([.command, .shift], "z"):
            return NSSelectorFromString("redo:")
        default:
            return nil
        }
    }

    static func performIfNeeded(for event: NSEvent, sender: AnyObject?) -> Bool {
        guard
            event.type == .keyDown,
            let action = action(
                forKeyEquivalent: event.charactersIgnoringModifiers ?? "",
                modifiers: event.modifierFlags
            )
        else {
            return false
        }

        return NSApplication.shared.sendAction(action, to: nil, from: sender)
    }
}

final class EditingShortcutWindow: NSWindow {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if EditingCommandRouter.performIfNeeded(for: event, sender: self) {
            return true
        }

        return super.performKeyEquivalent(with: event)
    }
}
