import CoreHaptics

@MainActor
final class HapticEngine {
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    func prepare() {
        guard supportsHaptics, engine == nil else { return }
        engine = try? CHHapticEngine()
        engine?.playsHapticsOnly = true
        engine?.resetHandler = { [weak self] in
            Task { @MainActor in
                try? self?.engine?.start()
            }
        }
        engine?.stoppedHandler = { [weak self] _ in
            Task { @MainActor in
                try? self?.engine?.start()
            }
        }
        try? engine?.start()
    }

    func tick() {
        play(events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 0.42),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.92)
                ],
                relativeTime: 0
            )
        ])
    }

    func shutter() {
        play(events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.35)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 0.72),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.88)
                ],
                relativeTime: 0.07
            )
        ])
    }

    func motor(duration: TimeInterval = 1.18) {
        play(events: [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 0.38),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.22)
                ],
                relativeTime: 0,
                duration: duration
            )
        ])
    }

    func paper() {
        play(events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 0.28),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.55)
                ],
                relativeTime: 0
            )
        ])
    }

    func shakeTick() {
        play(events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEvent.Parameter(parameterID: .hapticIntensity, value: 0.22),
                    CHHapticEvent.Parameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0
            )
        ])
    }

    private func play(events: [CHHapticEvent]) {
        prepare()
        guard supportsHaptics, let engine else { return }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            return
        }
    }
}
