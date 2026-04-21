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

@MainActor
@Test
func 点击空白关闭Trello后应恢复打开前的贴边位置与姿势() {
    let coordinator = makeCoordinator()
    coordinator.start()
    coordinator.handlePetDragEnded(windowOrigin: CGPoint(x: 0, y: 320))

    let originalPosition = coordinator.currentPetPositionForTesting
    let originalMode = coordinator.currentPetModeForTesting

    coordinator.showTrello()
    coordinator.hideTrelloAndRestorePet()

    #expect(coordinator.currentPetModeForTesting == originalMode)
    #expect(coordinator.currentPetPositionForTesting == originalPosition)
}

@MainActor
@Test
func 关闭Trello窗口后应恢复打开前的贴边位置与姿势() {
    let coordinator = makeCoordinator()
    coordinator.start()
    coordinator.handlePetDragEnded(windowOrigin: CGPoint(x: 0, y: 320))

    let originalPosition = coordinator.currentPetPositionForTesting
    let originalMode = coordinator.currentPetModeForTesting

    coordinator.showTrello()
    coordinator.simulatePanelWindowClosedForTesting()

    #expect(coordinator.currentPetModeForTesting == originalMode)
    #expect(coordinator.currentPetPositionForTesting == originalPosition)
}

@MainActor
private func makeCoordinator() -> AppCoordinator {
    let suiteName = "AppCoordinatorAnimationTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let store = AppPreferencesStore(userDefaults: defaults)
    return AppCoordinator(preferencesStore: store)
}
