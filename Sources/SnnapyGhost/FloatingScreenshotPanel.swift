import AppKit

@MainActor
final class FloatingScreenshotPanel: NSPanel {
    var onClose: (() -> Void)?

    init(image: NSImage, initialOrigin: CGPoint, displaySize: CGSize) {
        let frame = CGRect(
            origin: initialOrigin,
            size: CGSize(
                width: max(displaySize.width, 40),
                height: max(displaySize.height, 40)
            )
        )

        super.init(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        isFloatingPanel = true
        hidesOnDeactivate = false
        level = .screenSaver
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]
        isReleasedWhenClosed = false
        contentView = FloatingScreenshotView(image: image)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func close() {
        super.close()
        onClose?()
    }
}

@MainActor
private final class FloatingScreenshotView: NSView {
    private let imageView = NSImageView()
    private var dragStartPoint: NSPoint?
    private var windowStartOrigin: NSPoint?

    init(image: NSImage) {
        super.init(frame: CGRect(origin: .zero, size: image.size))

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        imageView.image = image
        imageView.imageScaling = .scaleAxesIndependently
        imageView.autoresizingMask = [.width, .height]
        imageView.frame = bounds
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 10
        imageView.layer?.masksToBounds = true
        imageView.layer?.borderColor = NSColor.white.withAlphaComponent(0.8).cgColor
        imageView.layer?.borderWidth = 1
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            window?.close()
            return
        }

        dragStartPoint = NSEvent.mouseLocation
        windowStartOrigin = window?.frame.origin
    }

    override func mouseDragged(with event: NSEvent) {
        guard
            let window,
            let dragStartPoint,
            let windowStartOrigin
        else {
            return
        }

        let currentPoint = NSEvent.mouseLocation
        let deltaX = currentPoint.x - dragStartPoint.x
        let deltaY = currentPoint.y - dragStartPoint.y

        window.setFrameOrigin(
            CGPoint(
                x: windowStartOrigin.x + deltaX,
                y: windowStartOrigin.y + deltaY
            )
        )
    }
}
