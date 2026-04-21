import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 可加载内置宠物目录() throws {
    let loader = PetCatalogLoader()

    let pets = try loader.loadAllPets()

    #expect(!pets.isEmpty)
    #expect(pets == pets.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    #expect(pets.contains(where: { $0.name == "Ayaka" }))
}
