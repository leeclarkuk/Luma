import CoreGraphics

enum LumaLayout {
    static let pillWidth: CGFloat = 126
    static let pillHeight: CGFloat = 37
    static let openWidth: CGFloat = 252
    static let openHeight: CGFloat = 304
    static let dragTravel: CGFloat = 268
    static let printWidth: CGFloat = 168
    static let printHeight: CGFloat = 204
    static let printInnerInset: CGFloat = 10
    static let printBottomBorder: CGFloat = 28
    static let shutterSize: CGFloat = 46
    static let islandOffset: CGFloat = 11

    static func bodyWidth(_ amount: CGFloat) -> CGFloat {
        pillWidth + (openWidth - pillWidth) * amount
    }

    static func bodyHeight(_ amount: CGFloat) -> CGFloat {
        pillHeight + (openHeight - pillHeight) * amount
    }

    static func cornerRadius(_ amount: CGFloat) -> CGFloat {
        18.5 + 10 * amount
    }
}
