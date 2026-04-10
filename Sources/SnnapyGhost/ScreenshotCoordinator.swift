import AppKit

@MainActor
final class ScreenshotCoordinator {
    private let permissionManager: PermissionManager

    private var overlayWindows: [SelectionOverlayWindow] = []
    private var panels: [FloatingScreenshotPanel] = []
    private var isSelectionActive = false

    init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    func beginCaptureFlow() {
        guard !isSelectionActive else { return }
        guard permissionManager.ensureScreenCaptureAccessForCapture() else { return }

        isSelectionActive = true
        overlayWindows = NSScreen.screens.map { screen in
            SelectionOverlayWindow(
                screen: screen,
                onComplete: { [weak self] localRect in
                    self?.completeSelection(on: screen, localRect: localRect)
                },
                onCancel: { [weak self] in
                    self?.cancelSelection()
                }
            )
        }

        for window in overlayWindows {
            window.orderFrontRegardless()
        }

        overlayWindows.first?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeAllPanels() {
        let existingPanels = panels
        panels.removeAll()
        existingPanels.forEach { $0.close() }
    }

    private func cancelSelection() {
        guard isSelectionActive else { return }
        tearDownOverlays()
    }

    private func completeSelection(on screen: NSScreen, localRect: CGRect) {
        guard isSelectionActive else { return }

        let standardizedLocalRect = localRect.standardized.integral
        guard standardizedLocalRect.width >= 2, standardizedLocalRect.height >= 2 else {
            cancelSelection()
            return
        }

        let globalRect = CGRect(
            x: screen.frame.origin.x + standardizedLocalRect.origin.x,
            y: screen.frame.origin.y + standardizedLocalRect.origin.y,
            width: standardizedLocalRect.width,
            height: standardizedLocalRect.height
        )

        tearDownOverlays()

        Task { [weak self] in
            guard let self else { return }

            do {
                guard #available(macOS 15.2, *) else {
                    self.permissionManager.presentUnsupportedSystemAlertAndTerminate()
                    return
                }

                let screenshot = try await ScreenCaptureService.captureImage(in: globalRect)
                let image = NSImage(cgImage: screenshot.cgImage, size: screenshot.size)
                self.presentFloatingPanel(image: image, initialFrame: globalRect)
            } catch {
                self.permissionManager.presentConfigurationAlert(
                    title: "截图失败",
                    message: "本次截图没有成功完成。\n\n错误信息：\(error.localizedDescription)"
                )
            }
        }
    }

    private func tearDownOverlays() {
        let windows = overlayWindows
        overlayWindows.removeAll()
        isSelectionActive = false
        windows.forEach { $0.close() }
    }

    private func presentFloatingPanel(image: NSImage, initialFrame: CGRect) {
        let panel = FloatingScreenshotPanel(
            image: image,
            initialOrigin: initialFrame.origin,
            displaySize: initialFrame.size
        )
        panel.onClose = { [weak self, weak panel] in
            guard let self, let panel else { return }
            self.panels.removeAll { $0 === panel }
        }

        panels.append(panel)
        panel.orderFrontRegardless()
    }
}
