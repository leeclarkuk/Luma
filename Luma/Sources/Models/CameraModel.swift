import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class CameraModel {
    var openAmount: CGFloat = 0
    var isDragging = false
    var phase: CameraPhase = .collapsed
    var photos: [InstantPhoto] = []
    var focusedID: InstantPhoto.ID?
    var isLiveCapture = false
    var isFlashing = false
    var shutterDepressed = false
    var flinch: CGFloat = 0
    var ejecting: EjectingPrint?
    var sceneTime: TimeInterval = 0
    var saveMessage: String?

    let capture = CaptureController()
    let feel = Feel()
    let shake = ShakeMonitor()
    let developmentDuration: TimeInterval

    private var didStart = false
    private var dragOrigin: CGFloat = 0
    private var lastDetentIndex = 0
    private var lastPulse: Date?
    private var isSnapping = false

    init(developmentDuration: TimeInterval = LumaRuntime.developmentDuration) {
        self.developmentDuration = developmentDuration
    }

    var layoutAmount: CGFloat { min(1, max(0, openAmount)) }

    var canSnap: Bool {
        layoutAmount >= 0.95
            && ejecting == nil
            && !isSnapping
            && focusedID == nil
            && (phase == .ready || phase == .developing || phase == .dragging)
    }

    var focusedPhoto: InstantPhoto? {
        photos.first { $0.id == focusedID }
    }

    var shelfPhotos: [InstantPhoto] {
        photos.filter(\.onShelf)
    }

    func start() {
        guard !didStart else { return }
        didStart = true
        feel.prepare()
        shake.onShake = { [weak self] in
            self?.handleShake()
        }
        shake.start()
        Task { [weak self] in
            guard let self else { return }
            self.isLiveCapture = await self.capture.start()
        }
    }

    func pulse(at date: Date) {
        if lastPulse == nil { lastPulse = date }
        let dt = date.timeIntervalSince(lastPulse ?? date)
        lastPulse = date
        sceneTime = date.timeIntervalSinceReferenceDate
        guard dt > 0, dt < 0.25 else { return }
        tickDevelopment(dt: dt)
    }

    func beginDrag() {
        guard ejecting == nil, !isSnapping, focusedID == nil else { return }
        isDragging = true
        dragOrigin = openAmount
        phase = .dragging
        lastDetentIndex = Detents.index(for: layoutAmount)
    }

    func updateDrag(translation: CGFloat) {
        guard isDragging else { return }
        let raw = dragOrigin + translation / LumaLayout.dragTravel
        let next = Detents.rubber(raw)
        let newIndex = Detents.index(for: min(max(next, 0), 1))
        if newIndex != lastDetentIndex {
            lastDetentIndex = newIndex
            feel.detentTick()
        }
        openAmount = next
    }

    func endDrag() {
        guard isDragging else { return }
        isDragging = false
        let target = Detents.nearest(openAmount)
        withAnimation(.interpolatingSpring(stiffness: 190, damping: 18)) {
            openAmount = target
        }
        lastDetentIndex = Detents.index(for: target)
        refreshPhase()
        if abs(target - 1) < 0.001 || abs(target) < 0.001 {
            feel.detentTick()
        }
    }

    func snap() {
        guard canSnap else { return }
        isSnapping = true
        phase = .capturing
        shutterDepressed = true
        feel.shutter()

        withAnimation(.easeOut(duration: 0.07)) {
            isFlashing = true
        }

        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 70_000_000)
            let frame = await self.grabFrame()

            try? await Task.sleep(nanoseconds: 90_000_000)
            withAnimation(.easeIn(duration: 0.2)) {
                self.isFlashing = false
            }

            withAnimation(.interpolatingSpring(stiffness: 420, damping: 14)) {
                self.flinch = 1
            }
            try? await Task.sleep(nanoseconds: 110_000_000)
            withAnimation(.interpolatingSpring(stiffness: 220, damping: 16)) {
                self.flinch = 0
            }

            let photo = InstantPhoto(image: frame)
            self.ejecting = EjectingPrint(photo: photo, progress: 0)
            self.phase = .ejecting
            self.shutterDepressed = false
            self.feel.motor()

            withAnimation(.timingCurve(0.18, 0.72, 0.22, 1.0, duration: 1.18)) {
                if var current = self.ejecting {
                    current.progress = 1
                    self.ejecting = current
                }
            }

            try? await Task.sleep(nanoseconds: 1_050_000_000)
            self.feel.paper()
            try? await Task.sleep(nanoseconds: 180_000_000)

            var landed = photo
            landed.onShelf = true
            self.photos.insert(landed, at: 0)
            self.ejecting = nil
            self.isSnapping = false
            self.refreshPhase()
        }
    }

    func focus(_ photo: InstantPhoto) {
        guard photo.onShelf, ejecting == nil else { return }
        focusedID = photo.id
        phase = .focused
        feel.detentTick()
    }

    func dismissFocus() {
        focusedID = nil
        refreshPhase()
    }

    func saveFocused() {
        guard let photo = focusedPhoto else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await PhotoLibrarySaver.save(photo.image)
                self.saveMessage = "Saved to Photos"
            } catch {
                self.saveMessage = "Could not save"
            }
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            if self.saveMessage != nil {
                self.saveMessage = nil
            }
        }
    }

    func handleShake() {
        var changed = false
        for index in photos.indices where photos[index].development < 1 {
            photos[index].development = DevelopmentChemistry.applyShake(photos[index].development)
            changed = true
        }
        if changed {
            feel.shakeTick()
        }
    }

    private func tickDevelopment(dt: TimeInterval) {
        guard photos.contains(where: { $0.development < 1 }) else { return }
        let shaking = shake.isShaking
        for index in photos.indices where photos[index].development < 1 {
            photos[index].development = DevelopmentChemistry.advance(
                progress: photos[index].development,
                dt: dt,
                duration: developmentDuration,
                shaking: shaking
            )
        }
        if phase == .developing, photos.allSatisfy(\.isDeveloped), focusedID == nil {
            phase = layoutAmount > 0.95 ? .ready : phase
        }
    }

    private func refreshPhase() {
        if focusedID != nil {
            phase = .focused
            return
        }
        if isSnapping || ejecting != nil {
            return
        }
        if layoutAmount < 0.05 {
            phase = .collapsed
        } else if layoutAmount > 0.95 {
            phase = .ready
        } else {
            phase = .dragging
        }
    }

    private func grabFrame() async -> UIImage {
        if isLiveCapture, let image = await capture.capturePhoto() {
            return image
        }
        return DemoSceneRenderer.snapshot(time: sceneTime)
    }
}
