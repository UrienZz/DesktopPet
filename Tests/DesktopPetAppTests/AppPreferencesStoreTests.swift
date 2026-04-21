import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 可持久化并恢复宠物名称与缩放值() {
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
