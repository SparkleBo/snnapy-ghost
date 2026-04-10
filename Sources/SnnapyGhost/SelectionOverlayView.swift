import AppKit

@MainActor
final class SelectionOverlayView: NSView {
    private let onComplete: (CGRect) -> Void
    private let onCancel: () -> Void

    private var dragStartPoint: CGPoint?
    private var currentPoint: CGPoint?

    init(
        frame frameRect: NSRect,
        onComplete: @escaping (CGRect) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onComplete = onComplete
        self.onCancel = onCancel
        super.init(frame: frameRect)
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onCancel()
            return
        }

        super.keyDown(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        dragStartPoint = point
        currentPoint = point
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true

        guard let selectionRect else {
            onCancel()
            return
        }

        onComplete(selectionRect)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.24).setFill()
        dirtyRect.fill()

        guard let selectionRect else { return }

        NSGraphicsContext.current?.cgContext.clear(selectionRect)

        let path = NSBezierPath(rect: selectionRect)
        path.lineWidth = 2
        NSColor.white.withAlphaComponent(0.95).setStroke()
        path.stroke()
    }

    private var selectionRect: CGRect? {
        guard let dragStartPoint, let currentPoint else { return nil }

        return CGRect(
            x: min(dragStartPoint.x, currentPoint.x),
            y: min(dragStartPoint.y, currentPoint.y),
            width: abs(currentPoint.x - dragStartPoint.x),
            height: abs(currentPoint.y - dragStartPoint.y)
        )
    }
}
