import Foundation
import Testing
@testable import DesktopPetApp

/// 验证首次选中未加载插件时会立即进入加载态。
@MainActor
@Test
func firstSelectingUnloadedPluginImmediatelyEntersLoadingState() {
    let state = PluginPanelSelectionState()
    let plugin = makePlugin(name: "Trello", url: "https://trello.com")

    state.syncSelection(availablePlugins: [plugin], preferredPluginID: plugin.id)

    #expect(state.selectedPluginID == plugin.id)
    #expect(state.isLoading)
}

/// 验证已加载插件再次选中时不会重复进入加载态。
@MainActor
@Test
func selectingLoadedPluginAgainDoesNotRepeatLoadingState() {
    let state = PluginPanelSelectionState()
    let first = makePlugin(name: "Trello", url: "https://trello.com")
    let second = makePlugin(name: "GitHub", url: "https://github.com")

    state.syncSelection(availablePlugins: [first, second], preferredPluginID: first.id)
    state.markFinishedLoading(pluginID: first.id, url: first.url)
    state.syncSelection(availablePlugins: [first, second], preferredPluginID: second.id)
    state.markFinishedLoading(pluginID: second.id, url: second.url)

    state.syncSelection(availablePlugins: [first, second], preferredPluginID: first.id)

    #expect(state.selectedPluginID == first.id)
    #expect(!state.isLoading)
}

/// 验证插件地址变更后会重新进入加载态。
@MainActor
@Test
func pluginURLChangeReentersLoadingState() {
    let state = PluginPanelSelectionState()
    let original = makePlugin(name: "Trello", url: "https://trello.com")
    let updated = PluginConfiguration(
        id: original.id,
        name: original.name,
        url: URL(string: "https://trello.com/b/new")!,
        iconName: original.iconName,
        isEnabled: true,
        sortOrder: original.sortOrder
    )

    state.syncSelection(availablePlugins: [original], preferredPluginID: original.id)
    state.markFinishedLoading(pluginID: original.id, url: original.url)
    state.syncSelection(availablePlugins: [updated], preferredPluginID: updated.id)

    #expect(state.selectedPluginID == updated.id)
    #expect(state.isLoading)
}

@MainActor
private func makePlugin(name: String, url: String) -> PluginConfiguration {
    PluginConfiguration(
        id: UUID(),
        name: name,
        url: URL(string: url)!,
        iconName: "puzzlepiece.extension",
        isEnabled: true,
        sortOrder: 0
    )
}
