import AppKit

@MainActor
final class SelectionOverlayWindow: NSWindow {
    init(
        screen: NSScreen,
        onComplete: @escaping (CGRect) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let contentRect = screen.frame
        let view = SelectionOverlayView(
            frame: CGRect(origin: .zero, size: contentRect.size),
            onComplete: onComplete,
            onCancel: onCancel
        )

        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .screenSaver
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        contentView = view
        ignoresMouseEvents = false
        isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
