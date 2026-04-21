import AppKit
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 主菜单应包含编辑菜单以支持全选复制粘贴快捷键() {
    let coordinator = AppCoordinator()
    coordinator.start()

    let menuTitles = NSApplication.shared.mainMenu?.items.map(\.title) ?? []
    let editMenu = NSApplication.shared.mainMenu?.items.first(where: { $0.title == "编辑" })?.submenu
    let editItemTitles = editMenu?.items.map(\.title) ?? []
    let copyAction = editMenu?.items.first(where: { $0.title == "复制" })?.action
    let pasteAction = editMenu?.items.first(where: { $0.title == "粘贴" })?.action
    let selectAllAction = editMenu?.items.first(where: { $0.title == "全选" })?.action
    let expectedCopyAction = NSSelectorFromString("copy:")
    let expectedPasteAction = NSSelectorFromString("paste:")
    let expectedSelectAllAction = NSSelectorFromString("selectAll:")

    #expect(menuTitles.contains("编辑"))
    #expect(editItemTitles.contains("全选"))
    #expect(editItemTitles.contains("复制"))
    #expect(editItemTitles.contains("粘贴"))
    #expect(copyAction == expectedCopyAction)
    #expect(pasteAction == expectedPasteAction)
    #expect(selectAllAction == expectedSelectAllAction)
}
