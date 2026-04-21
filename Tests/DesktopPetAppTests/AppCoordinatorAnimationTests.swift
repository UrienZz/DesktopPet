import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 启动时应恢复宠物动画暂停状态() {
    let suiteName = "AppCoordinatorAnimationTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    let store = AppPreferencesStore(userDefaults: defaults)
    store.savePetAnimationPaused(true)

    let coordinator = AppCoordinator(preferencesStore: store)
    coordinator.start()

    #expect(coordinator.isPetAnimationPaused == true)
}

@MainActor
@Test
func 切换动画暂停状态后应立即持久化() {
    let suiteName = "AppCoordinatorAnimationTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    let store = AppPreferencesStore(userDefaults: defaults)
    let coordinator = AppCoordinator(preferencesStore: store)
    coordinator.start()
    coordinator.togglePetAnimationPaused()

    #expect(coordinator.isPetAnimationPaused == true)
    #expect(store.loadPetAnimationPaused() == true)
}
