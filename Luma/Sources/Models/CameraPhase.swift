import Foundation
import CoreGraphics

enum CameraPhase: Equatable {
    case collapsed
    case dragging
    case ready
    case capturing
    case ejecting
    case developing
    case focused
}

enum LumaRuntime {
    static var developmentDuration: TimeInterval {
        if ProcessInfo.processInfo.arguments.contains("-luma-fast-chem") {
            return 3
        }
        return 18
    }

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-luma-fast-chem")
    }
}
