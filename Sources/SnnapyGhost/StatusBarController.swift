import AppKit

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private let permissionManager: PermissionManager
    private let onCaptureRequested: () -> Void

    private let statusItem: NSStatusItem
    private let permissionStatusItem = NSMenuItem()
    private let captureItem = NSMenuItem(
        title: "开始截图    control + shift + 2",
        action: nil,
        keyEquivalent: ""
    )

    init(permissionManager: PermissionManager, onCaptureRequested: @escaping () -> Void) {
        self.permissionManager = permissionManager
        self.onCaptureRequested = onCaptureRequested
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "camera.viewfinder",
                accessibilityDescription: "SnnapyGhost"
            )
            button.toolTip = "SnnapyGhost"
        }

        let menu = NSMenu()
        menu.delegate = self

        captureItem.target = self
        captureItem.action = #selector(handleCaptureRequest)
        menu.addItem(captureItem)

        permissionStatusItem.isEnabled = false
        menu.addItem(permissionStatusItem)

        let requestPermissionItem = NSMenuItem(
            title: "请求屏幕录制权限",
            action: #selector(handlePermissionRequest),
            keyEquivalent: ""
        )
        requestPermissionItem.target = self
        menu.addItem(requestPermissionItem)

        let openSettingsItem = NSMenuItem(
            title: "打开系统设置",
            action: #selector(handleOpenSettings),
            keyEquivalent: ""
        )
        openSettingsItem.target = self
        menu.addItem(openSettingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "退出 SnnapyGhost",
            action: #selector(handleQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        refreshPermissionStatus()
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshPermissionStatus()
    }

    private func refreshPermissionStatus() {
        permissionStatusItem.title = permissionManager.hasScreenCaptureAccess
            ? "屏幕录制权限：已开启"
            : "屏幕录制权限：未开启"
    }

    @objc
    private func handleCaptureRequest() {
        onCaptureRequested()
    }

    @objc
    private func handlePermissionRequest() {
        permissionManager.requestPermissionFromMenu()
    }

    @objc
    private func handleOpenSettings() {
        permissionManager.openSystemSettings()
    }

    @objc
    private func handleQuit() {
        NSApp.terminate(nil)
    }
}
