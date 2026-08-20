import AVFoundation
import Observation
import UIKit

@MainActor
@Observable
final class CaptureController: NSObject {
    private(set) var session: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()
    private var continuation: CheckedContinuation<UIImage?, Never>?

    func start() async -> Bool {
        if session != nil { return true }
        #if targetEnvironment(simulator)
        return false
        #else
        guard AVCaptureDevice.default(for: .video) != nil else { return false }

        let granted: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            granted = true
        case .notDetermined:
            granted = await AVCaptureDevice.requestAccess(for: .video)
        default:
            granted = false
        }
        guard granted else { return false }
        return configureSession()
        #endif
    }

    func capturePhoto() async -> UIImage? {
        guard session != nil else { return nil }
        for _ in 0..<20 where session?.isRunning != true {
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
        guard let session, session.isRunning else { return nil }
        return await withCheckedContinuation { continuation in
            if self.continuation != nil {
                continuation.resume(returning: nil)
                return
            }
            self.continuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func configureSession() -> Bool {
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input),
            captureSession.canAddOutput(photoOutput)
        else {
            captureSession.commitConfiguration()
            return false
        }

        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)
        if let connection = photoOutput.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        captureSession.commitConfiguration()
        session = captureSession

        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        return true
    }
}

extension CaptureController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage?
        if error == nil, let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }
        Task { @MainActor in
            continuation?.resume(returning: image)
            continuation = nil
        }
    }
}
