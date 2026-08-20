import CoreGraphics

struct DevelopmentLook: Equatable {
    var saturation: Double
    var contrast: Double
    var brightness: Double
    var blur: CGFloat
    var greenCast: Double

    static let undeveloped = DevelopmentLook(
        saturation: 0.18,
        contrast: 0.52,
        brightness: 0.34,
        blur: 5.5,
        greenCast: 0.16
    )

    static let developed = DevelopmentLook(
        saturation: 1.0,
        contrast: 1.04,
        brightness: 0.0,
        blur: 0,
        greenCast: 0
    )
}

enum DevelopmentChemistry {
    static let defaultDuration: TimeInterval = 18
    static let fastDuration: TimeInterval = 3
    static let shakeBoost: CGFloat = 0.14

    static func ease(_ linear: CGFloat) -> CGFloat {
        let x = min(max(linear, 0), 1)
        return x * x * (3 - 2 * x)
    }

    static func look(progress: CGFloat) -> DevelopmentLook {
        let t = Double(ease(progress))
        let a = DevelopmentLook.undeveloped
        let b = DevelopmentLook.developed
        return DevelopmentLook(
            saturation: a.saturation + (b.saturation - a.saturation) * t,
            contrast: a.contrast + (b.contrast - a.contrast) * t,
            brightness: a.brightness + (b.brightness - a.brightness) * t,
            blur: a.blur + (b.blur - a.blur) * CGFloat(t),
            greenCast: a.greenCast + (b.greenCast - a.greenCast) * t
        )
    }

    static func advance(progress: CGFloat, dt: TimeInterval, duration: TimeInterval, shaking: Bool) -> CGFloat {
        guard duration > 0 else { return 1 }
        let rate = CGFloat(dt / duration)
        let shake = shaking ? rate * 6 : 0
        return min(1, max(0, progress + rate + shake))
    }

    static func applyShake(_ progress: CGFloat, energy: CGFloat = shakeBoost) -> CGFloat {
        min(1, max(0, progress + energy))
    }
}
