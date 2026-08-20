import CoreGraphics

enum Detents {
    static let stops: [CGFloat] = [0, 0.28, 0.62, 1.0]

    static func rubber(_ value: CGFloat, minBound: CGFloat = 0, maxBound: CGFloat = 1, coefficient: CGFloat = 0.28) -> CGFloat {
        if value < minBound {
            return minBound - (minBound - value) * coefficient
        }
        if value > maxBound {
            return maxBound + (value - maxBound) * coefficient
        }
        return value
    }

    static func nearest(_ value: CGFloat, stops: [CGFloat] = stops) -> CGFloat {
        guard let match = stops.min(by: { abs($0 - value) < abs($1 - value) }) else {
            return value
        }
        return match
    }

    static func index(for value: CGFloat, stops: [CGFloat] = stops) -> Int {
        let clamped = min(max(value, stops.first ?? 0), stops.last ?? 1)
        return stops.lastIndex(where: { $0 <= clamped + 0.0001 }) ?? 0
    }
}
