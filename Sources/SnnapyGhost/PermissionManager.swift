import AppKit
import CoreGraphics

@MainActor
final class PermissionManager {
    var hasScreenCaptureAccess: Bool {
        CGPreflightScreenCaptureAccess()
    }

    func ensureScreenCaptureAccessForCapture() -> Bool {
        if hasScreenCaptureAccess {
            return true
        }

        let granted = CGRequestScreenCaptureAccess()
        if granted {
            return true
        }

        presentConfigurationAlert(
            title: "需要屏幕录制权限",
            message: """
            SnnapyGhost 需要“屏幕录制”权限才能截图。

            请在“系统设置 > 隐私与安全性 > 屏幕与系统音频录制”中允许本应用。

            如果你刚刚已经勾选了权限，macOS 通常需要你彻底退出并重新打开 SnnapyGhost，权限才会对当前进程生效。
            """
        )
        return false
    }

    func requestPermissionFromMenu() {
        if hasScreenCaptureAccess {
            presentConfigurationAlert(
                title: "权限已开启",
                message: "当前已经具备屏幕录制权限，可以直接使用 control + shift + 2 开始截图。"
            )
            return
        }

        _ = CGRequestScreenCaptureAccess()
        presentConfigurationAlert(
            title: "请完成权限授权",
            message: """
            系统权限请求已经触发。如果没有看到弹窗，请打开系统设置中的“屏幕与系统音频录制”并手动允许 SnnapyGhost。

            勾选权限后，请退出并重新打开应用，再开始截图。
            """
        )
    }

    func openSystemSettings() {
        let urls = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture",
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture"
        ]

        for rawValue in urls {
            guard let url = URL(string: rawValue) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    func presentUnsupportedSystemAlertAndTerminate() {
        presentConfigurationAlert(
            title: "系统版本不受支持",
            message: "SnnapyGhost v1 依赖 macOS 15.2+ 的截图 API。请在最新系统上运行。"
        )
        NSApp.terminate(nil)
    }

    func presentConfigurationAlert(title: String, message: String) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "知道了")

        if !hasScreenCaptureAccess {
            alert.addButton(withTitle: "打开系统设置")
        }

        let response = alert.runModal()
        if !hasScreenCaptureAccess, response == .alertSecondButtonReturn {
            openSystemSettings()
        }
    }
}
