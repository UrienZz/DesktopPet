import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let onClose: () -> Void

    init<Content: View>(rootView: Content, onClose: @escaping () -> Void) {
        self.onClose = onClose

        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 960, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Desktop Pet 设置"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.toolbar = nil
        window.center()
        window.contentView = NSHostingView(rootView: rootView)

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
