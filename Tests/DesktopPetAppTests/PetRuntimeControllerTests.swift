import CoreGraphics
import Testing
@testable import DesktopPetApp

@Test
func 运行态控制器默认进入右爬墙并支持切换宠物与缩放() throws {
    let pets = try PetCatalogLoader().loadAllPets()
    let controller = PetRuntimeController(
        availablePets: pets,
        initialScale: AppConstants.defaultPetScale
    )

    #expect(controller.currentMode == .climbRight)
    #expect(controller.currentScale == AppConstants.defaultPetScale)
    #expect(controller.currentPet.name == pets[0].name)

    let targetPet = pets.first(where: { $0.name == "Ayaka" })!
    controller.selectPet(named: targetPet.name)
    controller.updateScale(0.9)

    #expect(controller.currentPet.name == "Ayaka")
    #expect(controller.currentScale == 0.9)
}

@Test
func 重置后回到右侧中间默认位置() throws {
    let pets = try PetCatalogLoader().loadAllPets()
    let controller = PetRuntimeController(
        availablePets: pets,
        initialScale: AppConstants.defaultPetScale
    )

    let screenFrame = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let petSize = CGSize(width: 128, height: 128)

    controller.resetToDefaultPosition(screenFrame: screenFrame, petSize: petSize)

    #expect(controller.currentMode == .climbRight)
    #expect(abs(controller.currentPosition.x - (screenFrame.maxX - petSize.width)) < 0.001)
    #expect(abs(controller.currentPosition.y - ((screenFrame.height - petSize.height) / 2)) < 0.001)
}
