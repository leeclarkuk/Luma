import CoreMotion
import Foundation
import SwiftUI
import UIKit

extension Notification.Name {
    static let lumaDidShake = Notification.Name("lumaDidShake")
}

@MainActor
final class ShakeMonitor {
    var onShake: (() -> Void)?
    private(set) var isShaking = false

    private let motion = CMMotionManager()
    private var shakeUntil: Date?
    private var observer: NSObjectProtocol?

    func start() {
        observer = NotificationCenter.default.addObserver(
            forName: .lumaDidShake,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.registerShake()
            }
        }

        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 0.05
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }
            let a = data.userAcceleration
            let magnitude = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
            Task { @MainActor in
                guard let self else { return }
                if magnitude > 2.1 {
                    self.registerShake()
                }
            }
        }
    }

    private func registerShake() {
        isShaking = true
        shakeUntil = Date().addingTimeInterval(0.28)
        onShake?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            if let until = self.shakeUntil, Date() >= until {
                self.isShaking = false
            }
        }
    }

    deinit {
        motion.stopDeviceMotionUpdates()
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

struct ShakeCatcher: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ShakeViewController {
        ShakeViewController()
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
}

final class ShakeViewController: UIViewController {
    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .lumaDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}
