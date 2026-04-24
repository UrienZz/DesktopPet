import Foundation
import Testing
@testable import DesktopPetApp

/// 验证启动后会加载默认插件并选中首项。
@MainActor
@Test
func launchLoadsDefaultPluginAndSelectsFirst() throws {
    let coordinator = makeCoordinator()

    coordinator.start()

    #expect(coordinator.pluginsForTesting.count == 1)
    #expect(coordinator.pluginsForTesting.first?.name == "Trello")
    #expect(coordinator.selectedPluginForTesting?.name == "Trello")
}

/// 验证新增插件后会自动选中新项。
@MainActor
@Test
func addingPluginAutomaticallySelectsNewItem() throws {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.addPlugin()

    #expect(coordinator.pluginsForTesting.count == 2)
    #expect(coordinator.selectedPluginForTesting?.name == "未命名插件")
}

/// 验证删除最后一个插件后允许插件列表为空。
@MainActor
@Test
func deletingLastPluginAllowsEmptyList() throws {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.deleteSelectedPlugin()

    #expect(coordinator.pluginsForTesting.isEmpty)
    #expect(coordinator.selectedPluginForTesting == nil)
}

/// 验证拖拽排序后会按新顺序保存。
@MainActor
@Test
func reorderingPluginsSavesNewOrder() throws {
    let coordinator = makeCoordinator()
    coordinator.start()
    coordinator.addPlugin()
    coordinator.updateSelectedPlugin(
        name: "GitHub",
        urlString: "https://github.com",
        iconName: "chevron.left.forwardslash.chevron.right",
        isEnabled: true
    )

    coordinator.movePlugins(from: IndexSet(integer: 1), to: 0)

    #expect(coordinator.pluginsForTesting.map(\.name) == ["GitHub", "Trello"])
}

@MainActor
private func makeCoordinator() -> AppCoordinator {
    let suiteName = "AppCoordinatorPluginTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let preferencesStore = AppPreferencesStore(userDefaults: defaults)
    let pluginStore = PluginStore(userDefaults: defaults)
    return AppCoordinator(preferencesStore: preferencesStore, pluginStore: pluginStore)
}
