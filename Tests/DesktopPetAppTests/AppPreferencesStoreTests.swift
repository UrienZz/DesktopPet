import Foundation
import Testing
@testable import DesktopPetApp

/// 验证宠物名称与缩放值可以持久化并恢复。
@Test
func persistsAndRestoresPetNameAndScale() {
    let suiteName = "AppPreferencesStoreTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    let store = AppPreferencesStore(userDefaults: defaults)
    store.saveSelectedPetName("Ayaka")
    store.savePetScale(0.95)

    #expect(store.loadSelectedPetName() == "Ayaka")
    #expect(store.loadPetScale(defaultValue: AppConstants.defaultPetScale) == 0.95)
}

/// 验证宠物动画暂停状态可以持久化并恢复。
@Test
func persistsAndRestoresPetAnimationPausedState() {
    let suiteName = "AppPreferencesStoreTests-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    let store = AppPreferencesStore(userDefaults: defaults)
    store.savePetAnimationPaused(true)

    #expect(store.loadPetAnimationPaused() == true)
}
