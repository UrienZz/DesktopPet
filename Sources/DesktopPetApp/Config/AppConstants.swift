import Foundation

enum AppConstants {
    static let appName = "DesktopPetApp"
    static let trelloBoardURL = URL(string: "https://trello.com")!
    static let defaultPluginName = "Trello"
    static let defaultPluginURL = trelloBoardURL
    static let defaultPluginIconName = "tray.fill"

    static let defaultPetScale: Double = 0.7
    static let defaultEdgeInset: Double = 0
    static let defaultBottomInset: Double = 0
    static let snapThreshold: Double = 96
    static let panelSize = CGSize(width: 900, height: 640)
    static let settingsWindowSize = CGSize(width: 900, height: 640)
    static let petHoverGreetingDelayNanoseconds: UInt64 = 500_000_000
    static let selectedPetDefaultsKey = "selectedPetName"
    static let petScaleDefaultsKey = "petScale"
    static let petAnimationPausedDefaultsKey = "petAnimationPaused"
    static let pluginConfigurationsDefaultsKey = "pluginConfigurations"

    static let applicationSupportDirectoryURL = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first!.appendingPathComponent("DesktopPetApp", isDirectory: true)
    static let importedPetsDirectoryURL = applicationSupportDirectoryURL.appendingPathComponent("ImportedPets", isDirectory: true)

    static let configDirectoryURL = Bundle.module.resourceURL!
    static let mediaDirectoryURL = Bundle.module.resourceURL!
}
