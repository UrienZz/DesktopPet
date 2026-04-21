import AppKit

@MainActor
final class PetWindow: NSPanel {
    let renderView: PetRenderView

    init(renderView: PetRenderView) {
        self.renderView = renderView

        let initialRect = CGRect(origin: .zero, size: renderView.intrinsicContentSize)
        super.init(
            contentRect: initialRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .transient]
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = false
        hidesOnDeactivate = false

        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            standardWindowButton(button)?.isHidden = true
        }

        contentView = renderView
        resizeToFitContent()
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func resizeToFitContent() {
        let size = renderView.intrinsicContentSize
        setContentSize(size)
        renderView.frame = CGRect(origin: .zero, size: size)
    }

    func containsInteractiveScreenPoint(_ screenPoint: CGPoint) -> Bool {
        guard frame.contains(screenPoint) else { return false }
        let localPoint = CGPoint(
            x: screenPoint.x - frame.minX,
            y: screenPoint.y - frame.minY
        )
        return renderView.containsInteractivePixel(at: localPoint)
    }
}
