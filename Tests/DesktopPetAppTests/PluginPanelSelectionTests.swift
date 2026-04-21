import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 打开插件面板时应默认选择排序第一且启用的插件() throws {
    let coordinator = makeCoordinator()
    let plugins = [
        PluginConfiguration(
            id: UUID(),
            name: "GitHub",
            url: URL(string: "https://github.com")!,
            iconName: "chevron.left.forwardslash.chevron.right",
            isEnabled: true,
            sortOrder: 0
        ),
        PluginConfiguration(
            id: UUID(),
            name: "Trello",
            url: AppConstants.defaultPluginURL,
            iconName: "tray.fill",
            isEnabled: true,
            sortOrder: 1
        ),
    ]
    try coordinator.pluginStoreForTesting.savePlugins(plugins)
    coordinator.start()

    coordinator.preparePluginPanelForTesting()

    #expect(coordinator.selectedPanelPluginForTesting?.name == "GitHub")
}

@MainActor
@Test
func 全部禁用时插件面板应展示空状态() throws {
    let coordinator = makeCoordinator()
    let plugins = [
        PluginConfiguration(
            id: UUID(),
            name: "Trello",
            url: AppConstants.defaultPluginURL,
            iconName: "tray.fill",
            isEnabled: false,
            sortOrder: 0
        ),
    ]
    try coordinator.pluginStoreForTesting.savePlugins(plugins)
    coordinator.start()

    coordinator.preparePluginPanelForTesting()

    #expect(coordinator.selectedPanelPluginForTesting == nil)
    #expect(coordinator.isPluginPanelEmptyForTesting)
}

@MainActor
@Test
func 空列表时插件面板应展示空状态() throws {
    let coordinator = makeCoordinator()
    try coordinator.pluginStoreForTesting.savePlugins([])
    coordinator.start()

    coordinator.preparePluginPanelForTesting()

    #expect(coordinator.selectedPanelPluginForTesting == nil)
    #expect(coordinator.isPluginPanelEmptyForTesting)
}

@MainActor
private func makeCoordinator() -> AppCoordinator {
    let suiteName = "PluginPanelSelectionTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let preferencesStore = AppPreferencesStore(userDefaults: defaults)
    let pluginStore = PluginStore(userDefaults: defaults)
    return AppCoordinator(preferencesStore: preferencesStore, pluginStore: pluginStore)
}
