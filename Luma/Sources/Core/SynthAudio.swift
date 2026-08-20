import AVFoundation
import Foundation

@MainActor
final class SynthAudio {
    static var isEnabled: Bool {
        #if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["LUMA_AUDIO"] == "1"
        #else
        true
        #endif
    }

    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?
    private var format: AVAudioFormat?

    func prepare() {
        guard Self.isEnabled, engine == nil else { return }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2) else { return }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            player.play()
        } catch {
            return
        }

        self.engine = engine
        self.player = player
        self.format = format
    }

    func playClick() {
        schedule(Self.click)
    }

    func playShutter() {
        schedule(Self.shutter)
    }

    func playMotor() {
        schedule(Self.motor)
    }

    func playPaper() {
        schedule(Self.paper)
    }

    func playShake() {
        schedule(Self.shake)
    }

    private func schedule(_ factory: (AVAudioFormat) -> AVAudioPCMBuffer?) {
        prepare()
        guard let player, let format, let buffer = factory(format) else { return }
        player.scheduleBuffer(buffer, at: nil, options: [])
    }

    private static func click(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        render(format: format, duration: 0.018) { t, _ in
            let env = exp(-t * 220)
            let click = sin(2 * .pi * 2_400 * t) * 0.35 + noise(t) * 0.2
            return Float(click * env)
        }
    }

    private static func shutter(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        render(format: format, duration: 0.16) { t, _ in
            let slapT = t
            let slapEnv = slapT < 0.035 ? exp(-slapT * 90) : 0
            let slap = (sin(2 * .pi * 92 * slapT) * 0.7 + noise(t) * 0.25) * slapEnv

            let curtainT = t - 0.072
            let curtainEnv = curtainT > 0 && curtainT < 0.03 ? exp(-curtainT * 140) : 0
            let curtain = (sin(2 * .pi * 420 * max(0, curtainT)) * 0.45 + noise(t + 3) * 0.18) * curtainEnv
            return Float(slap + curtain)
        }
    }

    private static func motor(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        render(format: format, duration: 1.22) { t, duration in
            let env = envelope(t, duration: duration, attack: 0.05, release: 0.18)
            let whir = sin(2 * .pi * (410 + t * 70) * t) * 0.08
            let grind = bandLimitedNoise(t, cutoff: 1_100) * 0.22
            return Float((whir + grind) * env)
        }
    }

    private static func paper(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        render(format: format, duration: 0.38) { t, duration in
            let env = envelope(t, duration: duration, attack: 0.02, release: 0.12)
            let rustle = bandLimitedNoise(t, cutoff: 2_800) * 0.28
            let slip = sin(2 * .pi * (180 - t * 90) * t) * 0.05
            return Float((rustle + slip) * env)
        }
    }

    private static func shake(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        render(format: format, duration: 0.05) { t, _ in
            Float(noise(t) * exp(-t * 60) * 0.15)
        }
    }

    private static func render(
        format: AVAudioFormat,
        duration: Double,
        sample: (Double, Double) -> Float
    ) -> AVAudioPCMBuffer? {
        let frames = AVAudioFrameCount(duration * format.sampleRate)
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
            let left = buffer.floatChannelData
        else { return nil }

        buffer.frameLength = frames
        let channels = Int(format.channelCount)
        let rate = format.sampleRate
        for i in 0..<Int(frames) {
            let t = Double(i) / rate
            let value = sample(t, duration)
            for ch in 0..<channels {
                left[ch][i] = value
            }
        }
        return buffer
    }

    private static func envelope(_ t: Double, duration: Double, attack: Double, release: Double) -> Double {
        let a = min(1, t / max(attack, 0.001))
        let r = t > duration - release ? max(0, (duration - t) / max(release, 0.001)) : 1
        return a * r
    }

    private static func noise(_ t: Double) -> Double {
        var seed = t.bitPattern &+ 0x9E3779B97F4A7C15
        seed = seed &* 6364136223846793005 &+ 1
        let u = Double(seed >> 11) / 0x1.0p53
        return u * 2 - 1
    }

    private static func bandLimitedNoise(_ t: Double, cutoff: Double) -> Double {
        let n = noise(t) + noise(t * 1.7) * 0.5
        return n * min(1, cutoff / 4_000)
    }
}
