import AppKit
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 标准编辑快捷键应映射到对应selector() {
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

@MainActor
@Test
func 非编辑快捷键不应被路由器接管() {
    #expect(
        EditingCommandRouter.action(
            forKeyEquivalent: "p",
            modifiers: [.command]
        ) == nil
    )
}
