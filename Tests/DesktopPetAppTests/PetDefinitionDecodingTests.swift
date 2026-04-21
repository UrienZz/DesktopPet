import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 可解码旧项目宠物定义() throws {
    let sampleURL = AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json")
    let data = try Data(contentsOf: sampleURL)

    let pet = try JSONDecoder().decode(PetDefinition.self, from: data)

    #expect(pet.name == "Ayaka")
    #expect(pet.imageSource == "media/Ayaka.png")
    #expect(pet.frameSize == 128)
    #expect(pet.states["climb"]?.frameMax == 8)
    #expect(pet.states["stand"]?.spriteLine == 1)
    #expect(pet.source == .bundled)
    #expect(!pet.isImported)
    #expect(pet.storageDirectoryURL == nil)
}

@Test
func 运行态应将底边与拖拽动作解析到sit和drag() {
    let pet = PetDefinition(
        name: "Custom",
        imageSource: "media/custom.png",
        frameSize: 128,
        width: nil,
        height: nil,
        highestFrameMax: nil,
        totalSpriteLine: nil,
        states: [
            "stand": PetStateDefinition(spriteLine: 1, frameMax: 1, start: nil, end: nil),
            "sit": PetStateDefinition(spriteLine: 2, frameMax: 1, start: nil, end: nil),
            "drag": PetStateDefinition(spriteLine: 3, frameMax: 1, start: nil, end: nil),
        ]
    )

    #expect(pet.resolvedStateName(for: .bottomIdle) == "sit")
    #expect(pet.resolvedStateName(for: .dragging) == "drag")
}
