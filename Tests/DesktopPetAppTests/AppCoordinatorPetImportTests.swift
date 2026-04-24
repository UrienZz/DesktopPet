import Foundation
import Testing
@testable import DesktopPetApp

/// 验证导入宠物后会刷新宠物列表。
@MainActor
@Test
func importingPetRefreshesCatalogList() throws {
    let harness = try makeHarness()
    let archiveURL = try makePetArchive(
        workspace: harness.workspace,
        petName: "Imported Lumine",
        imageSource: "media/imported-lumine.png",
        includePNG: true
    )

    harness.coordinator.start()
    try harness.coordinator.importPetArchive(at: archiveURL)

    #expect(harness.coordinator.availablePets.contains(where: { $0.name == "Imported Lumine" && $0.isImported }))
}

/// 验证删除当前导入宠物时会回退到默认内置宠物。
@MainActor
@Test
func deletingCurrentImportedPetFallsBackToDefaultBundledPet() throws {
    let harness = try makeHarness()
    let archiveURL = try makePetArchive(
        workspace: harness.workspace,
        petName: "Imported Ganyu",
        imageSource: "media/imported-ganyu.png",
        includePNG: true
    )

    harness.coordinator.start()
    let fallbackPetName = try #require(harness.coordinator.availablePets.first?.name)
    try harness.coordinator.importPetArchive(at: archiveURL)
    harness.coordinator.updateSelectedPet("Imported Ganyu")
    harness.preferencesStore.saveSelectedPetName("Imported Ganyu")

    try harness.coordinator.deleteCurrentImportedPet()

    #expect(harness.coordinator.currentPet?.name == fallbackPetName)
    #expect(harness.preferencesStore.loadSelectedPetName() == fallbackPetName)
    #expect(!harness.coordinator.availablePets.contains(where: { $0.name == "Imported Ganyu" }))
}

@MainActor
private func makeHarness() throws -> (
    workspace: ImportedPetWorkspace,
    preferencesStore: AppPreferencesStore,
    coordinator: AppCoordinator
) {
    let workspace = try makeWorkspace(named: "coordinator-import")
    let suiteName = "AppCoordinatorPetImportTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let preferencesStore = AppPreferencesStore(userDefaults: defaults)
    let importedPetStore = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let catalogLoader = PetCatalogLoader(
        bundledConfigDirectoryURL: AppConstants.configDirectoryURL,
        importedPetStore: importedPetStore
    )
    let coordinator = AppCoordinator(
        preferencesStore: preferencesStore,
        pluginStore: PluginStore(userDefaults: defaults),
        catalogLoader: catalogLoader,
        importedPetStore: importedPetStore
    )
    return (workspace, preferencesStore, coordinator)
}
