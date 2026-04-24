import Foundation
import Testing
@testable import DesktopPetApp

/// 验证启动时会恢复宠物动画暂停状态。
@MainActor
@Test
func launchRestoresPetAnimationPausedState() {
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

/// 验证切换动画暂停状态后会立即持久化。
@MainActor
@Test
func togglingAnimationPausedStatePersistsImmediately() {
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

/// 验证点击空白关闭 Trello 后会恢复打开前的贴边位置与姿势。
@MainActor
@Test
func blankClickClosingTrelloRestoresPreviousEdgePositionAndPose() {
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

/// 验证关闭 Trello 窗口后会恢复打开前的贴边位置与姿势。
@MainActor
@Test
func closingTrelloWindowRestoresPreviousEdgePositionAndPose() {
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

/// 验证悬停延迟触发前不会进入打招呼姿势。
@MainActor
@Test
func hoverBeforeDelayDoesNotEnterGreetingPose() {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.simulatePetHoverChangedForTesting(true)

    #expect(coordinator.currentForcedStateNameForTesting == nil)
}

/// 验证悬停延迟触发后进入打招呼姿势并在移出后恢复。
@MainActor
@Test
func hoverAfterDelayEntersGreetingPoseAndExitRestores() {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.simulatePetHoverChangedForTesting(true)
    coordinator.triggerPendingPetHoverGreetingForTesting()
    #expect(coordinator.currentForcedStateNameForTesting == "greet")

    coordinator.simulatePetHoverChangedForTesting(false)
    #expect(coordinator.currentForcedStateNameForTesting == nil)
}

/// 验证点击打开面板后会清除打招呼姿势并保持现有面板状态。
@MainActor
@Test
func openingPanelClearsGreetingPoseAndKeepsPanelState() {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.simulatePetHoverChangedForTesting(true)
    coordinator.triggerPendingPetHoverGreetingForTesting()
    #expect(coordinator.currentForcedStateNameForTesting == "greet")

    coordinator.showTrello()

    #expect(coordinator.currentForcedStateNameForTesting == nil)
    #expect(coordinator.currentPetModeForTesting == .hovering)
}

/// 验证关闭面板后再次悬停仍会进入打招呼姿势。
@MainActor
@Test
func hoverStillEntersGreetingPoseAfterPanelCloses() {
    let coordinator = makeCoordinator()
    coordinator.start()

    coordinator.showTrello()
    coordinator.hideTrelloAndRestorePet()

    coordinator.simulatePetHoverChangedForTesting(true)
    coordinator.triggerPendingPetHoverGreetingForTesting()

    #expect(coordinator.currentForcedStateNameForTesting == "greet")
}

@MainActor
private func makeCoordinator() -> AppCoordinator {
    let suiteName = "AppCoordinatorAnimationTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    let store = AppPreferencesStore(userDefaults: defaults)
    return AppCoordinator(preferencesStore: store)
}
