import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = AppCoordinator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        coordinator.start()
    }

    @objc
    func handleCloseShortcut() {
        Task { @MainActor in
            coordinator.performWindowClose()
        }
    }
}
