import AppKit
import CoreGraphics
import ScreenCaptureKit

struct ScreenCaptureRequest: Sendable {
    let displayID: CGDirectDisplayID
    let globalRect: CGRect
    let sourceRect: CGRect
    let scaleFactor: CGFloat
}

struct CapturedScreenshot: @unchecked Sendable {
    let cgImage: CGImage
    let size: CGSize
}

enum ScreenCaptureServiceError: LocalizedError {
    case invalidRect
    case displayNotFound(CGDirectDisplayID)
    case noImage
    case noImageWithContext(String)

    var errorDescription: String? {
        switch self {
        case .invalidRect:
            return "截图区域无效。"
        case let .displayNotFound(displayID):
            return "没有找到对应的显示器（displayID: \(displayID)）。"
        case .noImage:
            return "系统没有返回截图图像。"
        case let .noImageWithContext(context):
            return "系统没有返回截图图像。\n\n上下文：\(context)"
        }
    }
}

enum ScreenCaptureService {
    @available(macOS 15.2, *)
    static func captureImage(request: ScreenCaptureRequest) async throws -> CapturedScreenshot {
        let globalRect = request.globalRect.standardized.integral
        let sourceRect = request.sourceRect.standardized.integral

        guard
            globalRect.width >= 1,
            globalRect.height >= 1,
            sourceRect.width >= 1,
            sourceRect.height >= 1
        else {
            throw ScreenCaptureServiceError.invalidRect
        }

        let scale = max(request.scaleFactor, 1)
        let width = max(Int(round(sourceRect.width * scale)), 1)
        let height = max(Int(round(sourceRect.height * scale)), 1)

        do {
            let shareableContent = try await SCShareableContent.current
            guard let display = shareableContent.displays.first(where: { $0.displayID == request.displayID }) else {
                throw ScreenCaptureServiceError.displayNotFound(request.displayID)
            }

            let filter = SCContentFilter(
                display: display,
                excludingApplications: [],
                exceptingWindows: []
            )

            let configuration = SCStreamConfiguration()
            configuration.sourceRect = sourceRect
            configuration.width = width
            configuration.height = height
            configuration.showsCursor = false

            let image = try await captureImage(contentFilter: filter, configuration: configuration)
            return CapturedScreenshot(cgImage: image, size: sourceRect.size)
        } catch ScreenCaptureServiceError.noImage {
            let fallbackImage = try await captureImageInGlobalRect(globalRect, context: request.debugContext)
            return CapturedScreenshot(cgImage: fallbackImage, size: globalRect.size)
        } catch {
            throw error
        }
    }

    @available(macOS 15.2, *)
    private static func captureImage(
        contentFilter: SCContentFilter,
        configuration: SCStreamConfiguration
    ) async throws -> CGImage {
        try await withCheckedThrowingContinuation { continuation in
            SCScreenshotManager.captureImage(
                contentFilter: contentFilter,
                configuration: configuration
            ) { capturedImage, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let capturedImage else {
                    continuation.resume(throwing: ScreenCaptureServiceError.noImage)
                    return
                }

                continuation.resume(returning: capturedImage)
            }
        }
    }

    @available(macOS 15.2, *)
    private static func captureImageInGlobalRect(_ rect: CGRect, context: String) async throws -> CGImage {
        try await withCheckedThrowingContinuation { continuation in
            SCScreenshotManager.captureImage(in: rect) { capturedImage, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let capturedImage else {
                    continuation.resume(throwing: ScreenCaptureServiceError.noImageWithContext(context))
                    return
                }

                continuation.resume(returning: capturedImage)
            }
        }
    }
}

private extension ScreenCaptureRequest {
    var debugContext: String {
        "displayID=\(displayID), globalRect=\(NSStringFromRect(globalRect)), sourceRect=\(NSStringFromRect(sourceRect)), scaleFactor=\(scaleFactor)"
    }
}
