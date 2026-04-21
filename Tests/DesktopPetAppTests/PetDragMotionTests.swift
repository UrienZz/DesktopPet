import CoreGraphics
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 拖拽位移应基于屏幕坐标而不是窗口局部坐标() {
    let startOrigin = CGPoint(x: 800, y: 400)
    let mouseDown = CGPoint(x: 1000, y: 700)
    let current = CGPoint(x: 920, y: 620)

    let newOrigin = PetRenderView.draggedWindowOrigin(
        startWindowOrigin: startOrigin,
        mouseDownScreenPoint: mouseDown,
        currentMouseScreenPoint: current
    )

    #expect(newOrigin.x == 720)
    #expect(newOrigin.y == 320)
}
