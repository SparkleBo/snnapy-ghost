import AppKit
import Carbon.HIToolbox

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let permissionManager = PermissionManager()
    private var screenshotCoordinator: ScreenshotCoordinator!
    private var statusBarController: StatusBarController!
    private var hotKeyMonitor: HotKeyMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard #available(macOS 15.2, *) else {
            permissionManager.presentUnsupportedSystemAlertAndTerminate()
            return
        }

        screenshotCoordinator = ScreenshotCoordinator(permissionManager: permissionManager)
        statusBarController = StatusBarController(
            permissionManager: permissionManager,
            onCaptureRequested: { [weak self] in
                self?.screenshotCoordinator.beginCaptureFlow()
            }
        )

        do {
            hotKeyMonitor = try HotKeyMonitor(
                keyCode: UInt32(kVK_ANSI_2),
                modifiers: UInt32(controlKey) | UInt32(shiftKey),
                onKeyDown: { [weak self] in
                    self?.screenshotCoordinator.beginCaptureFlow()
                }
            )
        } catch {
            permissionManager.presentConfigurationAlert(
                title: "全局快捷键注册失败",
                message: "无法注册 control + shift + 2。你仍然可以从菜单栏手动触发截图。\n\n错误信息：\(error.localizedDescription)"
            )
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        screenshotCoordinator?.closeAllPanels()
    }
}
