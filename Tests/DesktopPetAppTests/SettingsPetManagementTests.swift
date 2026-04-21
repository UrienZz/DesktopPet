import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 当前内置宠物不应显示删除入口() throws {
    let harness = try makeSettingsHarness()

    harness.coordinator.start()

    #expect(harness.coordinator.currentPetSourceDisplayTitle == "内置")
    #expect(!harness.coordinator.canDeleteCurrentImportedPet)
}

@MainActor
@Test
func 当前导入宠物应显示自定义来源与删除入口() throws {
    let harness = try makeSettingsHarness()
    let archiveURL = try makePetArchive(
        workspace: harness.workspace,
        petName: "Imported Furina",
        imageSource: "media/imported-furina.png",
        includePNG: true
    )

    harness.coordinator.start()
    try harness.coordinator.importPetArchive(at: archiveURL)
    harness.coordinator.updateSelectedPet("Imported Furina")

    #expect(harness.coordinator.currentPetSourceDisplayTitle == "自定义")
    #expect(harness.coordinator.canDeleteCurrentImportedPet)
}

@MainActor
private func makeSettingsHarness() throws -> (
    workspace: ImportedPetWorkspace,
    coordinator: AppCoordinator
) {
    let workspace = try makeWorkspace(named: "settings-pet-management")
    let suiteName = "SettingsPetManagementTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let importedPetStore = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let catalogLoader = PetCatalogLoader(
        bundledConfigDirectoryURL: AppConstants.configDirectoryURL,
        importedPetStore: importedPetStore
    )
    let coordinator = AppCoordinator(
        preferencesStore: AppPreferencesStore(userDefaults: defaults),
        pluginStore: PluginStore(userDefaults: defaults),
        catalogLoader: catalogLoader,
        importedPetStore: importedPetStore
    )
    return (workspace, coordinator)
}
