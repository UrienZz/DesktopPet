import Foundation
import Testing
@testable import DesktopPetApp

/// 验证首次启动时会注入默认 Trello 插件。
@Test
func firstLaunchInjectsDefaultTrelloPlugin() throws {
    let defaults = makeDefaults()
    let store = PluginStore(userDefaults: defaults)

    let plugins = try store.loadPlugins()

    #expect(plugins.count == 1)
    #expect(plugins[0].name == "Trello")
    #expect(plugins[0].url == AppConstants.defaultPluginURL)
    #expect(plugins[0].isEnabled)
    #expect(plugins[0].sortOrder == 0)
}

/// 验证用户主动删空插件后不会再次自动补回默认 Trello。
@Test
func emptyUserPluginListDoesNotReinjectDefaultTrello() throws {
    let defaults = makeDefaults()
    let store = PluginStore(userDefaults: defaults)

    _ = try store.loadPlugins()
    try store.savePlugins([])

    let plugins = try store.loadPlugins()

    #expect(plugins.isEmpty)
}

/// 验证全部插件禁用时可展示插件列表为空。
@Test
func visiblePluginsAreEmptyWhenAllPluginsDisabled() throws {
    let defaults = makeDefaults()
    let store = PluginStore(userDefaults: defaults)
    let plugin = PluginConfiguration(
        id: UUID(),
        name: "Trello",
        url: AppConstants.defaultPluginURL,
        iconName: "tray.fill",
        isEnabled: false,
        sortOrder: 0
    )

    try store.savePlugins([plugin])

    let visiblePlugins = try store.loadVisiblePlugins()

    #expect(visiblePlugins.isEmpty)
}

private func makeDefaults() -> UserDefaults {
    let suiteName = "PluginStoreTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
}
