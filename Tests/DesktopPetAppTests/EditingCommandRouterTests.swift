import AppKit
import Testing
@testable import DesktopPetApp

/// 验证标准编辑快捷键会映射到对应 selector。
@MainActor
@Test
func standardEditingShortcutsMapToSelectors() {
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "a",
            modifiers: [.command]
        ) == NSSelectorFromString("selectAll:")
    )
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "c",
            modifiers: [.command]
        ) == NSSelectorFromString("copy:")
    )
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "v",
            modifiers: [.command]
        ) == NSSelectorFromString("paste:")
    )
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "x",
            modifiers: [.command]
        ) == NSSelectorFromString("cut:")
    )
}

/// 验证非编辑快捷键不会被编辑路由器接管。
@MainActor
@Test
func nonEditingShortcutsAreNotHandledByRouter() {
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "p",
            modifiers: [.command]
        ) == nil
    )
}
