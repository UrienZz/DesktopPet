import AppKit
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 打开设置时应刷新应用图标() {
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
