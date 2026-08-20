import Photos
import UIKit

enum PhotoLibrarySaver {
    enum SaveError: Error {
        case denied
        case failed
    }

    static func save(_ image: UIImage) async throws {
        let granted = await requestAddOnly()
        guard granted else { throw SaveError.denied }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? SaveError.failed)
                }
            })
        }
    }

    private static func requestAddOnly() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let next = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return next == .authorized || next == .limited
        default:
            return false
        }
    }
}
