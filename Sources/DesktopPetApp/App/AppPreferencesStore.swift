import Foundation

struct AppPreferencesStore {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSelectedPetName(_ petName: String) {
        userDefaults.set(petName, forKey: AppConstants.selectedPetDefaultsKey)
    }

    func loadSelectedPetName() -> String? {
        userDefaults.string(forKey: AppConstants.selectedPetDefaultsKey)
    }

    func savePetScale(_ scale: Double) {
        userDefaults.set(scale, forKey: AppConstants.petScaleDefaultsKey)
    }

    func loadPetScale(defaultValue: Double) -> Double {
        let value = userDefaults.double(forKey: AppConstants.petScaleDefaultsKey)
        return value > 0 ? value : defaultValue
    }

    func savePetAnimationPaused(_ isPaused: Bool) {
        userDefaults.set(isPaused, forKey: AppConstants.petAnimationPausedDefaultsKey)
    }

    func loadPetAnimationPaused() -> Bool {
        userDefaults.bool(forKey: AppConstants.petAnimationPausedDefaultsKey)
    }
}
