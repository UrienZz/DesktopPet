import Foundation

struct PluginStore {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadPlugins() throws -> [PluginConfiguration] {
        guard let data = userDefaults.data(forKey: AppConstants.pluginConfigurationsDefaultsKey) else {
            let defaultPlugins = [Self.defaultPlugin(sortOrder: 0)]
            try savePlugins(defaultPlugins)
            return defaultPlugins
        }

        let plugins = try decoder.decode([PluginConfiguration].self, from: data)
        return plugins.sorted(by: Self.sortPlugins)
    }

    func loadVisiblePlugins() throws -> [PluginConfiguration] {
        try loadPlugins().filter(\.isEnabled)
    }

    func savePlugins(_ plugins: [PluginConfiguration]) throws {
        let normalized = plugins
            .enumerated()
            .map { index, plugin in
                var mutablePlugin = plugin
                mutablePlugin.sortOrder = index
                return mutablePlugin
            }
        let data = try encoder.encode(normalized)
        userDefaults.set(data, forKey: AppConstants.pluginConfigurationsDefaultsKey)
    }

    static func defaultPlugin(sortOrder: Int) -> PluginConfiguration {
        PluginConfiguration(
            id: UUID(),
            name: AppConstants.defaultPluginName,
            url: AppConstants.defaultPluginURL,
            iconName: AppConstants.defaultPluginIconName,
            isEnabled: true,
            sortOrder: sortOrder
        )
    }

    private static func sortPlugins(_ lhs: PluginConfiguration, _ rhs: PluginConfiguration) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }

        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
