import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 启动后应加载默认插件并选中首项() throws {
    let coordinator = makeCoordinator()

    coordinator.start()

    #expect(coordinator.pluginsForTesting.count == 1)
    #expect(coordinator.pluginsForTesting.first?.name == "Trello")
    #expect(coordinator.selectedPluginForTesting?.name == "Trello")
}

@MainActor
@Test
func 新增插件后应自动选中新项() throws {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.addPlugin()

    #expect(coordinator.pluginsForTesting.count == 2)
    #expect(coordinator.selectedPluginForTesting?.name == "未命名插件")
}

@MainActor
@Test
func 删除最后一个插件后应允许为空列表() throws {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.deleteSelectedPlugin()

    #expect(coordinator.pluginsForTesting.isEmpty)
    #expect(coordinator.selectedPluginForTesting == nil)
}

@MainActor
@Test
func 拖拽排序后应按新顺序保存() throws {
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
