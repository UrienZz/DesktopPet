import Foundation
import Testing
@testable import DesktopPetApp

/// 验证打开插件面板时默认选择排序第一且启用的插件。
@MainActor
@Test
func openingPluginPanelSelectsFirstEnabledPluginBySortOrder() throws {
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

/// 验证全部插件禁用时插件面板展示空状态。
@MainActor
@Test
func pluginPanelShowsEmptyStateWhenAllPluginsDisabled() throws {
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

/// 验证插件列表为空时插件面板展示空状态。
@MainActor
@Test
func pluginPanelShowsEmptyStateWhenPluginListIsEmpty() throws {
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
