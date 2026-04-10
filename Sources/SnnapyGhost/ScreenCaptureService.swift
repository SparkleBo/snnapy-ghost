import AppKit
import CoreGraphics
import ScreenCaptureKit

struct CapturedScreenshot: @unchecked Sendable {
    let cgImage: CGImage
    let size: CGSize
}

enum ScreenCaptureServiceError: LocalizedError {
    case invalidRect
    case noImage

    var errorDescription: String? {
        switch self {
        case .invalidRect:
            return "截图区域无效。"
        case .noImage:
            return "系统没有返回截图图像。"
        }
    }
}

enum ScreenCaptureService {
    @available(macOS 15.2, *)
    static func captureImage(in rect: CGRect) async throws -> CapturedScreenshot {
        let standardizedRect = rect.standardized.integral
        guard standardizedRect.width >= 1, standardizedRect.height >= 1 else {
            throw ScreenCaptureServiceError.invalidRect
        }

        let image: CGImage = try await withCheckedThrowingContinuation { continuation in
            SCScreenshotManager.captureImage(in: standardizedRect) { capturedImage, error in
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

        return CapturedScreenshot(cgImage: image, size: standardizedRect.size)
    }
}
