import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = AppCoordinator()
    private let applicationIconUpdater = ApplicationIconUpdater()

    func applicationDidFinishLaunching(_ notification: Notification) {
        applicationIconUpdater.applyApplicationIcon()
        coordinator.start()
    }

    @objc
    func handleCloseShortcut() {
        Task { @MainActor in
            coordinator.performWindowClose()
        }
    }
}
