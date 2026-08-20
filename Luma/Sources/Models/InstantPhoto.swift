import Foundation
import UIKit

struct InstantPhoto: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let capturedAt: Date
    var development: CGFloat
    var onShelf: Bool

    init(
        id: UUID = UUID(),
        image: UIImage,
        capturedAt: Date = Date(),
        development: CGFloat = 0,
        onShelf: Bool = false
    ) {
        self.id = id
        self.image = image
        self.capturedAt = capturedAt
        self.development = development
        self.onShelf = onShelf
    }

    var isDeveloped: Bool { development >= 1 }

    var look: DevelopmentLook {
        DevelopmentChemistry.look(progress: development)
    }

    static func == (lhs: InstantPhoto, rhs: InstantPhoto) -> Bool {
        lhs.id == rhs.id
            && lhs.development == rhs.development
            && lhs.onShelf == rhs.onShelf
            && lhs.capturedAt == rhs.capturedAt
    }
}

struct EjectingPrint: Equatable {
    var photo: InstantPhoto
    var progress: CGFloat
}
