import SwiftUI
import UIKit

struct DemoSceneView: View {
    var time: TimeInterval

    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            DemoSceneRenderer.draw(context: context, size: size, time: time)
        }
        .accessibilityHidden(true)
    }
}

enum DemoSceneRenderer {
    @MainActor
    static func snapshot(time: TimeInterval, size: CGSize = CGSize(width: 800, height: 800)) -> UIImage {
        let view = DemoSceneView(time: time)
            .frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        renderer.proposedSize = ProposedViewSize(size)
        if let image = renderer.uiImage {
            return image
        }
        return fallbackImage(size: size, time: time)
    }

    static func draw(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let rect = CGRect(origin: .zero, size: size)
        let sky = Gradient(colors: [
            Color(red: 0.07, green: 0.09, blue: 0.22),
            Color(red: 0.18, green: 0.16, blue: 0.38),
            Color(red: 0.72, green: 0.38, blue: 0.28),
            Color(red: 0.95, green: 0.62, blue: 0.32)
        ])
        context.fill(
            Path(rect),
            with: .linearGradient(
                sky,
                startPoint: CGPoint(x: size.width * 0.5, y: 0),
                endPoint: CGPoint(x: size.width * 0.5, y: size.height)
            )
        )

        var rng = UInt64(truncatingIfNeeded: 0xC0FFEE)
        for i in 0..<48 {
            rng = rng &* 6364136223846793005 &+ 1
            let sx = CGFloat(rng % 1000) / 1000 * size.width
            rng = rng &* 6364136223846793005 &+ 1
            let sy = CGFloat(rng % 1000) / 1000 * size.height * 0.55
            rng = rng &* 6364136223846793005 &+ 1
            let twinkle = 0.45 + 0.55 * (0.5 + 0.5 * sin(time * 1.7 + Double(i)))
            let starSize = 1.1 + CGFloat(rng % 18) / 10
            var star = context
            star.opacity = twinkle
            star.fill(
                Path(ellipseIn: CGRect(x: sx, y: sy, width: starSize, height: starSize)),
                with: .color(.white)
            )
        }

        let moonCenter = CGPoint(
            x: size.width * 0.72,
            y: size.height * 0.22 + CGFloat(sin(time * 0.15)) * 4
        )
        let moonR = min(size.width, size.height) * 0.07
        context.fill(
            Path(ellipseIn: CGRect(
                x: moonCenter.x - moonR,
                y: moonCenter.y - moonR,
                width: moonR * 2,
                height: moonR * 2
            )),
            with: .color(Color(red: 0.98, green: 0.93, blue: 0.82))
        )
        var crater = context
        crater.opacity = 0.18
        crater.fill(
            Path(ellipseIn: CGRect(
                x: moonCenter.x - moonR * 0.15,
                y: moonCenter.y - moonR * 0.35,
                width: moonR * 0.55,
                height: moonR * 0.4
            )),
            with: .color(.gray)
        )

        var hills = Path()
        hills.move(to: CGPoint(x: 0, y: size.height))
        var x: CGFloat = 0
        while x <= size.width {
            let y = size.height * 0.68
                + sin(x / 42 + time * 0.08) * 16
                + sin(x / 18) * 8
            hills.addLine(to: CGPoint(x: x, y: y))
            x += 4
        }
        hills.addLine(to: CGPoint(x: size.width, y: size.height))
        hills.closeSubpath()
        context.fill(hills, with: .color(Color(red: 0.05, green: 0.06, blue: 0.1)))

        var nearHills = Path()
        nearHills.move(to: CGPoint(x: 0, y: size.height))
        x = 0
        while x <= size.width {
            let y = size.height * 0.82 + sin(x / 28 + 1.7) * 10
            nearHills.addLine(to: CGPoint(x: x, y: y))
            x += 4
        }
        nearHills.addLine(to: CGPoint(x: size.width, y: size.height))
        nearHills.closeSubpath()
        context.fill(nearHills, with: .color(Color(red: 0.02, green: 0.02, blue: 0.05)))

        context.fill(
            Path(rect),
            with: .radialGradient(
                Gradient(colors: [.clear, Color.black.opacity(0.35)]),
                center: CGPoint(x: size.width * 0.5, y: size.height * 0.45),
                startRadius: min(size.width, size.height) * 0.25,
                endRadius: max(size.width, size.height) * 0.72
            )
        )
    }

    private static func fallbackImage(size: CGSize, time: TimeInterval) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.07, green: 0.09, blue: 0.22, alpha: 1).cgColor,
                UIColor(red: 0.95, green: 0.62, blue: 0.32, alpha: 1).cgColor
            ]
            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            ) {
                cg.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: 0, y: size.height),
                    options: []
                )
            }
            _ = time
        }
    }
}
