import Testing
@testable import DesktopPetApp

@Test
func 运行态初始化时优先恢复已选择宠物与缩放() throws {
    let pets = try PetCatalogLoader().loadAllPets()

    let controller = PetRuntimeController(
        availablePets: pets,
        initialScale: 1.05,
        initialPetName: "Ayaka"
    )

    #expect(controller.currentPet.name == "Ayaka")
    #expect(controller.currentScale == 1.05)
    #expect(controller.currentMode == .climbRight)
}
