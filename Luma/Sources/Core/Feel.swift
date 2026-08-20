import Foundation

@MainActor
final class Feel {
    private let audio = SynthAudio()
    private let haptics = HapticEngine()

    func prepare() {
        audio.prepare()
        haptics.prepare()
    }

    func detentTick() {
        audio.playClick()
        haptics.tick()
    }

    func shutter() {
        audio.playShutter()
        haptics.shutter()
    }

    func motor() {
        audio.playMotor()
        haptics.motor()
    }

    func paper() {
        audio.playPaper()
        haptics.paper()
    }

    func shakeTick() {
        audio.playShake()
        haptics.shakeTick()
    }
}
