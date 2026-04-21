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
}
