import Foundation
import Testing
@testable import DesktopPetApp

/// 验证可以加载内置宠物目录。
@Test
func loadsBundledPetCatalog() throws {
    let loader = PetCatalogLoader()

    let pets = try loader.loadAllPets()

    #expect(!pets.isEmpty)
    #expect(pets == pets.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    #expect(pets.contains(where: { $0.name == "Ayaka" }))
    #expect(pets.contains(where: { $0.name == "Batman" }))
}

/// 验证可以同时加载内置宠物和导入宠物。
@Test
func loadsBundledAndImportedPetCatalogs() throws {
    let workspace = try makeWorkspace(named: "catalog-loader")
    let importedStore = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let archiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Imported Mona",
        imageSource: "media/imported-mona.png",
        includePNG: true
    )
    _ = try importedStore.importPetArchive(from: archiveURL)

    let loader = PetCatalogLoader(
        bundledConfigDirectoryURL: AppConstants.configDirectoryURL,
        importedPetStore: importedStore
    )

    let pets = try loader.loadAllPets()

    #expect(pets.contains(where: { $0.name == "Ayaka" && $0.source == PetSource.bundled }))
    #expect(pets.contains(where: { $0.name == "Imported Mona" && $0.source == PetSource.imported }))
}
