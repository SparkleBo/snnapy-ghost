import Carbon
import Foundation

enum HotKeyMonitorError: LocalizedError {
    case installHandler(OSStatus)
    case registerHotKey(OSStatus)

    var errorDescription: String? {
        switch self {
        case let .installHandler(status):
            return "InstallEventHandler 失败（\(status)）"
        case let .registerHotKey(status):
            return "RegisterEventHotKey 失败（\(status)）"
        }
    }
}

final class HotKeyMonitor {
    private static let signature = OSType(0x53474B59) // SGKY
    private static let eventHandler: EventHandlerUPP = { _, event, userData in
        guard
            let event,
            let userData
        else {
            return noErr
        }

        let monitor = Unmanaged<HotKeyMonitor>.fromOpaque(userData).takeUnretainedValue()
        return monitor.handleEvent(event)
    }

    private let onKeyDown: @MainActor @Sendable () -> Void
    private let hotKeyID: EventHotKeyID

    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?

    init(
        keyCode: UInt32,
        modifiers: UInt32,
        onKeyDown: @escaping @MainActor @Sendable () -> Void
    ) throws {
        self.onKeyDown = onKeyDown
        self.hotKeyID = EventHotKeyID(signature: Self.signature, id: 1)

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let pointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            Self.eventHandler,
            1,
            &eventType,
            pointer,
            &eventHandlerRef
        )

        guard installStatus == noErr else {
            throw HotKeyMonitorError.installHandler(installStatus)
        }

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr else {
            if let eventHandlerRef {
                RemoveEventHandler(eventHandlerRef)
            }
            throw HotKeyMonitorError.registerHotKey(registerStatus)
        }
    }

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    private func handleEvent(_ event: EventRef) -> OSStatus {
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr else {
            return status
        }

        guard hotKeyID.signature == Self.signature, hotKeyID.id == self.hotKeyID.id else {
            return noErr
        }

        Task { @MainActor [onKeyDown] in
            onKeyDown()
        }

        return noErr
    }
}
