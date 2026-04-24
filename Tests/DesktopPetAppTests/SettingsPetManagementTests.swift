import Foundation
import Testing
@testable import DesktopPetApp

/// 验证当前宠物为内置宠物时不显示删除入口。
@MainActor
@Test
func bundledPetDoesNotShowDeleteAction() throws {
    let harness = try makeSettingsHarness()

    harness.coordinator.start()

    #expect(harness.coordinator.currentPetSourceDisplayTitle == "内置")
    #expect(!harness.coordinator.canDeleteCurrentImportedPet)
}

/// 验证当前宠物为导入宠物时显示自定义来源和删除入口。
@MainActor
@Test
func importedPetShowsCustomSourceAndDeleteAction() throws {
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
