import AppKit
import SwiftUI

@MainActor
final class PanelWindow: NSPanel, NSWindowDelegate {
    private let onClose: () -> Void

    init<Content: View>(
        rootView: Content,
        title: String = "插件面板",
        onClose: @escaping () -> Void = {}
    ) {
        self.onClose = onClose
        super.init(
            contentRect: CGRect(origin: .zero, size: AppConstants.panelSize),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.title = title
        titlebarAppearsTransparent = true
        isReleasedWhenClosed = false
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentView = NSHostingView(rootView: rootView)
        delegate = self
    }

    func show(anchoredTo petFrame: CGRect) {
        let origin = CGPoint(
            x: max(24, petFrame.minX - AppConstants.panelSize.width - 20),
            y: max(24, petFrame.midY - (AppConstants.panelSize.height / 2))
        )
        setFrameOrigin(origin)
        makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if EditingCommandRouter.performIfNeeded(for: event, sender: self) {
            return true
        }

        return super.performKeyEquivalent(with: event)
    }
}
