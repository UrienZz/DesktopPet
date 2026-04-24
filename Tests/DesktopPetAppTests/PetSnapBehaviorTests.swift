import CoreGraphics
import Testing
@testable import DesktopPetApp

/// 验证拖拽松手到底边时优先吸附到底边站立。
@Test
func releaseAtBottomSnapsToBottomIdle() throws {
    let controller = try makeRuntimeController()
    let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
    let petSize = CGSize(width: 128, height: 128)

    controller.moveDraggedPet(to: CGPoint(x: 40, y: 10))
    controller.handleDrop(screenFrame: screen, petSize: petSize)

    #expect(controller.currentMode == .bottomIdle)
    #expect(abs(controller.currentPosition.y - screen.minY) < 0.001)
}

/// 验证拖拽松手到左边缘时进入左爬墙状态。
@Test
func releaseAtLeftEdgeEntersLeftClimbing() throws {
    let controller = try makeRuntimeController()
    let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
    let petSize = CGSize(width: 128, height: 128)

    controller.moveDraggedPet(to: CGPoint(x: 12, y: 300))
    controller.handleDrop(screenFrame: screen, petSize: petSize)

    #expect(controller.currentMode == .climbLeft)
    #expect(abs(controller.currentPosition.x - screen.minX) < 0.001)
}

/// 验证拖拽松手到右边缘时进入右爬墙状态。
@Test
func releaseAtRightEdgeEntersRightClimbing() throws {
    let controller = try makeRuntimeController()
    let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
    let petSize = CGSize(width: 128, height: 128)

    controller.moveDraggedPet(to: CGPoint(x: 1100, y: 280))
    controller.handleDrop(screenFrame: screen, petSize: petSize)

    #expect(controller.currentMode == .climbRight)
    #expect(abs(controller.currentPosition.x - (screen.maxX - petSize.width)) < 0.001)
}

/// 验证顶部松手时先进入下落再落地站立。
@Test
func releaseAtTopFallsBeforeLandingAtBottom() throws {
    let controller = try makeRuntimeController()
    let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
    let petSize = CGSize(width: 128, height: 128)

    controller.moveDraggedPet(to: CGPoint(x: 520, y: 760))
    controller.handleDrop(screenFrame: screen, petSize: petSize)

    #expect(controller.currentMode == .falling)

    controller.completeFallIfNeeded()

    #expect(controller.currentMode == .bottomIdle)
    #expect(abs(controller.currentPosition.y - screen.minY) < 0.001)
}

/// 验证中间区域松手时自然下落到底边站立。
@Test
func releaseInMiddleFallsNaturallyToBottomIdle() throws {
    let controller = try makeRuntimeController()
    let screen = CGRect(x: 0, y: 0, width: 1200, height: 800)
    let petSize = CGSize(width: 128, height: 128)

    controller.moveDraggedPet(to: CGPoint(x: 520, y: 400))
    controller.handleDrop(screenFrame: screen, petSize: petSize)

    #expect(controller.currentMode == .falling)

    controller.completeFallIfNeeded()

    #expect(controller.currentMode == .bottomIdle)
    #expect(abs(controller.currentPosition.y - screen.minY) < 0.001)
}

private func makeRuntimeController() throws -> PetRuntimeController {
    let pets = try PetCatalogLoader().loadAllPets()
    return PetRuntimeController(availablePets: pets, initialScale: AppConstants.defaultPetScale)
}
