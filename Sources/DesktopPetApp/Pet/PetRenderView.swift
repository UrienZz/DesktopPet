import AppKit

@MainActor
final class PetRenderView: NSView {
    var pet: PetDefinition {
        didSet { reloadFrames() }
    }

    var runtimeMode: PetRuntimeMode {
        didSet { reloadFrames() }
    }

    var forcedStateName: String? {
        didSet { reloadFrames() }
    }

    var forceMirrored = false {
        didSet { reloadFrames() }
    }

    var isAnimationPaused = false {
        didSet { updateFrameAnimationTimer() }
    }

    var scaleFactor: CGFloat {
        didSet {
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }

    var interactionEnabled = true
    var onTap: (() -> Void)?
    var onDragEnded: ((CGPoint) -> Void)?

    private var spriteSheet: CGImage?
    private var frameImages: [CGImage] = []
    private var currentFrameIndex = 0
    private var isMirrored = false
    private var mouseDownScreenPoint: CGPoint = .zero
    private var dragStartOrigin: CGPoint = .zero
    private var isDragging = false
    private var frameAdvanceTimer: Timer?

    init(pet: PetDefinition, runtimeMode: PetRuntimeMode, scaleFactor: CGFloat) {
        self.pet = pet
        self.runtimeMode = runtimeMode
        self.scaleFactor = scaleFactor
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        reloadFrames()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        let animator = try? SpriteSheetAnimator(pet: pet)
        let width = CGFloat(animator?.frameWidth ?? 128) * scaleFactor
        let height = CGFloat(animator?.frameHeight ?? 128) * scaleFactor
        return CGSize(width: width, height: height)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard !frameImages.isEmpty else { return }

        let image = frameImages[currentFrameIndex]
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.interpolationQuality = .none
        let drawRect = bounds

        if isMirrored {
            context.translateBy(x: drawRect.width, y: 0)
            context.scaleBy(x: -1, y: 1)
        }

        context.draw(image, in: drawRect)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard interactionEnabled else { return nil }
        return containsInteractivePixel(at: point) ? self : nil
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        guard interactionEnabled else { return }
        isDragging = false
        mouseDownScreenPoint = NSEvent.mouseLocation
        dragStartOrigin = window?.frame.origin ?? .zero
    }

    override func mouseDragged(with event: NSEvent) {
        guard interactionEnabled, let window else { return }

        let currentPoint = NSEvent.mouseLocation
        let deltaX = currentPoint.x - mouseDownScreenPoint.x
        let deltaY = currentPoint.y - mouseDownScreenPoint.y

        if hypot(deltaX, deltaY) > 2 {
            isDragging = true
        }

        guard isDragging else { return }

        let newOrigin = Self.draggedWindowOrigin(
            startWindowOrigin: dragStartOrigin,
            mouseDownScreenPoint: mouseDownScreenPoint,
            currentMouseScreenPoint: currentPoint
        )
        window.setFrameOrigin(newOrigin)
    }

    override func mouseUp(with event: NSEvent) {
        guard interactionEnabled else { return }

        if isDragging {
            onDragEnded?(window?.frame.origin ?? .zero)
        } else {
            onTap?()
        }
    }

    private func reloadFrames() {
        invalidateFrameAnimationTimer()
        currentFrameIndex = 0
        spriteSheet = NSImage(contentsOf: pet.mediaFileURL)?
            .cgImage(forProposedRect: nil, context: nil, hints: nil)

        guard
            let spriteSheet,
            let animator = try? SpriteSheetAnimator(pet: pet)
        else {
            frameImages = []
            needsDisplay = true
            return
        }

        let stateName = forcedStateName ?? pet.resolvedStateName(for: runtimeMode)
        let frameRange = (try? animator.frameRange(for: stateName)) ?? 0...0
        isMirrored = forceMirrored || (forcedStateName == nil && runtimeMode == .climbLeft)
        frameImages = frameRange
            .compactMap { cropFrame(from: spriteSheet, frameIndex: $0, animator: animator) }
            .filter { !isFullyTransparent($0) }

        if frameImages.isEmpty, stateName != pet.preferredStandingStateName {
            let fallbackRange = (try? animator.frameRange(for: pet.preferredStandingStateName)) ?? 0...0
            frameImages = fallbackRange
                .compactMap { cropFrame(from: spriteSheet, frameIndex: $0, animator: animator) }
                .filter { !isFullyTransparent($0) }
        }

        updateFrameAnimationTimer()
        invalidateIntrinsicContentSize()
        needsDisplay = true
    }

    func containsInteractivePixel(at localPoint: NSPoint) -> Bool {
        isOpaquePixel(at: localPoint)
    }

    static func draggedWindowOrigin(
        startWindowOrigin: CGPoint,
        mouseDownScreenPoint: CGPoint,
        currentMouseScreenPoint: CGPoint
    ) -> CGPoint {
        CGPoint(
            x: startWindowOrigin.x + (currentMouseScreenPoint.x - mouseDownScreenPoint.x),
            y: startWindowOrigin.y + (currentMouseScreenPoint.y - mouseDownScreenPoint.y)
        )
    }

    @objc
    private func advanceFrame() {
        guard !frameImages.isEmpty else { return }
        currentFrameIndex = (currentFrameIndex + 1) % frameImages.count
        needsDisplay = true
    }

    private func cropFrame(from spriteSheet: CGImage, frameIndex: Int, animator: SpriteSheetAnimator) -> CGImage? {
        let rect = Self.cropRect(
            frameIndex: frameIndex,
            imageWidth: spriteSheet.width,
            imageHeight: spriteSheet.height,
            frameWidth: animator.frameWidth,
            frameHeight: animator.frameHeight
        )
        return spriteSheet.cropping(to: rect)
    }

    static func cropRect(
        frameIndex: Int,
        imageWidth: Int,
        imageHeight: Int,
        frameWidth: Int,
        frameHeight: Int
    ) -> CGRect {
        let columns = max(1, imageWidth / frameWidth)
        let column = frameIndex % columns
        let row = frameIndex / columns
        let x = column * frameWidth
        let y = row * frameHeight
        return CGRect(x: x, y: min(max(0, y), max(0, imageHeight - frameHeight)), width: frameWidth, height: frameHeight)
    }

    private func isFullyTransparent(_ image: CGImage) -> Bool {
        guard
            let dataProvider = image.dataProvider,
            let data = dataProvider.data,
            let bytes = CFDataGetBytePtr(data)
        else {
            return false
        }

        let bytesPerPixel = image.bitsPerPixel / 8
        guard bytesPerPixel >= 4 else { return false }

        for py in 0..<image.height {
            for px in 0..<image.width {
                let index = py * image.bytesPerRow + px * bytesPerPixel + 3
                if bytes[index] > 0 {
                    return false
                }
            }
        }

        return true
    }

    private func isOpaquePixel(at localPoint: NSPoint) -> Bool {
        guard
            !frameImages.isEmpty,
            bounds.contains(localPoint)
        else {
            return false
        }

        let image = frameImages[currentFrameIndex]
        let xRatio = localPoint.x / max(bounds.width, 1)
        let yRatio = localPoint.y / max(bounds.height, 1)

        var pixelX = Int(xRatio * CGFloat(image.width))
        var pixelY = Int(yRatio * CGFloat(image.height))

        if isMirrored {
            pixelX = max(0, image.width - 1 - pixelX)
        }

        pixelX = min(max(pixelX, 0), image.width - 1)
        pixelY = min(max(pixelY, 0), image.height - 1)

        guard
            let dataProvider = image.dataProvider,
            let data = dataProvider.data,
            let bytes = CFDataGetBytePtr(data)
        else {
            return true
        }

        let bytesPerPixel = image.bitsPerPixel / 8
        guard bytesPerPixel >= 4 else { return true }

        let index = pixelY * image.bytesPerRow + pixelX * bytesPerPixel + 3
        return bytes[index] > 0
    }

    private func updateFrameAnimationTimer() {
        invalidateFrameAnimationTimer()

        guard !isAnimationPaused, frameImages.count > 1 else {
            needsDisplay = true
            return
        }

        let timer = Timer(
            timeInterval: 1.0 / 9.0,
            target: self,
            selector: #selector(advanceFrame),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer, forMode: .common)
        frameAdvanceTimer = timer
    }

    private func invalidateFrameAnimationTimer() {
        frameAdvanceTimer?.invalidate()
        frameAdvanceTimer = nil
    }

    var isFrameAnimationActiveForTesting: Bool {
        frameAdvanceTimer != nil
    }
}
