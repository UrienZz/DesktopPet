import Foundation

@MainActor
final class PluginPanelSelectionState: ObservableObject {
    @Published private(set) var selectedPluginID: UUID?
    @Published private(set) var isLoading = false

    private var loadedURLsByPluginID: [UUID: URL] = [:]

    func syncSelection(availablePlugins: [PluginConfiguration], preferredPluginID: UUID?) {
        let visiblePlugins = availablePlugins.filter(\.isEnabled)
        let visiblePluginIDs = Set(visiblePlugins.map(\.id))
        loadedURLsByPluginID = loadedURLsByPluginID.filter { visiblePluginIDs.contains($0.key) }

        let nextSelection: UUID?
        if let preferredPluginID, visiblePluginIDs.contains(preferredPluginID) {
            nextSelection = preferredPluginID
        } else {
            nextSelection = visiblePlugins.first?.id
        }

        selectedPluginID = nextSelection

        guard
            let nextSelection,
            let selectedPlugin = visiblePlugins.first(where: { $0.id == nextSelection })
        else {
            isLoading = false
            return
        }

        isLoading = loadedURLsByPluginID[nextSelection] != selectedPlugin.url
    }

    func markStartedLoading(pluginID: UUID) {
        guard selectedPluginID == pluginID else { return }
        isLoading = true
    }

    func markFinishedLoading(pluginID: UUID, url: URL) {
        loadedURLsByPluginID[pluginID] = url

        guard selectedPluginID == pluginID else { return }
        isLoading = false
    }

    func markFailedLoading(pluginID: UUID) {
        guard selectedPluginID == pluginID else { return }
        isLoading = false
    }
}
