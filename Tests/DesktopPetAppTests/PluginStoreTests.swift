import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 首次启动应注入默认Trello插件() throws {
    let defaults = makeDefaults()
    let store = PluginStore(userDefaults: defaults)

    let plugins = try store.loadPlugins()

    #expect(plugins.count == 1)
    #expect(plugins[0].name == "Trello")
    #expect(plugins[0].url == AppConstants.defaultPluginURL)
    #expect(plugins[0].isEnabled)
    #expect(plugins[0].sortOrder == 0)
}

@Test
func 用户删空后不应再次自动补回默认Trello() throws {
    let defaults = makeDefaults()
    let store = PluginStore(userDefaults: defaults)

    _ = try store.loadPlugins()
    try store.savePlugins([])

    let plugins = try store.loadPlugins()

    #expect(plugins.isEmpty)
}

@Test
func 全部禁用时可展示插件列表应为空() throws {
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
