import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 关闭Trello窗口时会触发关闭回调() {
    var didClose = false
    let window = PanelWindow(rootView: TrelloPanelView()) {
        didClose = true
    }

    window.close()

    #expect(didClose)
}
