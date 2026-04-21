import AppKit
import SwiftUI

@MainActor
final class PanelWindow: NSPanel {
    init(rootView: TrelloPanelView) {
        super.init(
            contentRect: CGRect(origin: .zero, size: AppConstants.panelSize),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        title = "Trello"
        titlebarAppearsTransparent = true
        isReleasedWhenClosed = false
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentView = NSHostingView(rootView: rootView)
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
}
