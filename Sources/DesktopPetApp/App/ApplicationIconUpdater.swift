import AppKit
import Foundation

@MainActor
protocol ApplicationIconUpdating: AnyObject {
    func applyApplicationIcon()
}

@MainActor
final class ApplicationIconUpdater: ApplicationIconUpdating {
    private let application: NSApplication
    private let resourceBundle: Bundle

    init(
        application: NSApplication = .shared,
        resourceBundle: Bundle = .module
    ) {
        self.application = application
        self.resourceBundle = resourceBundle
    }

    func applyApplicationIcon() {
        guard
            let iconURL = resourceBundle.url(forResource: "AppIcon", withExtension: "png"),
            let iconImage = NSImage(contentsOf: iconURL)
        else {
            return
        }

        application.applicationIconImage = iconImage
    }
}
