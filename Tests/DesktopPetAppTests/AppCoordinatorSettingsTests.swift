import AppKit
import Testing
@testable import DesktopPetApp

/// 验证打开设置时会刷新应用图标显示。
@MainActor
@Test
func openingSettingsRefreshesAppIcon() {
    let iconUpdater = SpyApplicationIconUpdater()
    let coordinator = AppCoordinator(applicationIconUpdater: iconUpdater)

    coordinator.openSettings()

    #expect(iconUpdater.applyCount == 1)
    coordinator.performWindowClose()
}

@MainActor
private final class SpyApplicationIconUpdater: ApplicationIconUpdating {
    private(set) var applyCount = 0

    func applyApplicationIcon() {
        applyCount += 1
    }
}
