import SwiftUI

struct InstantPrintCard: View {
    var photo: InstantPhoto
    var compact: Bool
    var index: Int?

    private var look: DevelopmentLook { photo.look }

    var body: some View {
        let width = compact ? 118 : LumaLayout.printWidth
        let height = compact ? 144 : LumaLayout.printHeight
        let inset = compact ? 7.0 : LumaLayout.printInnerInset
        let bottom = compact ? 20.0 : LumaLayout.printBottomBorder

        VStack(spacing: 0) {
            ZStack {
                Color(red: 0.93, green: 0.94, blue: 0.9)
                Image(uiImage: photo.image)
                    .resizable()
                    .scaledToFill()
                    .saturation(look.saturation)
                    .contrast(look.contrast)
                    .brightness(look.brightness)
                    .blur(radius: look.blur * (compact ? 0.55 : 1))
                    .overlay {
                        Color(red: 0.42, green: 0.78, blue: 0.38)
                            .opacity(look.greenCast)
                            .blendMode(.overlay)
                    }
                    .overlay {
                        Color.white.opacity(0.22 * (1 - Double(photo.development)))
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .padding(inset)
            .padding(.bottom, 0)

            Text(stamp)
                .font(.system(size: compact ? 7 : 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.black.opacity(0.35))
                .frame(maxWidth: .infinity, minHeight: bottom, maxHeight: bottom)
        }
        .frame(width: width, height: height)
        .background(Color(red: 0.97, green: 0.97, blue: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: compact ? 4 : 5, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: compact ? 8 : 12, y: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("Instant print")
        .accessibilityValue(photo.isDeveloped ? "developed" : "developing")
        .accessibilityAddTraits(.isButton)
    }

    private var identifier: String {
        if let index {
            return "luma.print.\(index)"
        }
        return "luma.print"
    }

    private var stamp: String {
        photo.capturedAt.formatted(date: .omitted, time: .shortened)
    }
}
