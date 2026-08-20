import SwiftUI

struct CameraBodyView: View {
    @Bindable var model: CameraModel

    private var amount: CGFloat { model.layoutAmount }
    private var rubber: CGFloat { model.openAmount - amount }

    var body: some View {
        let width = LumaLayout.bodyWidth(amount)
        let height = LumaLayout.bodyHeight(amount) + rubber * 36
        let radius = LumaLayout.cornerRadius(amount)

        VStack(spacing: 0) {
            stem
            ZStack(alignment: .top) {
                bodyPlastic(width: width, height: height, radius: radius)

                if amount > 0.12 {
                    innerContent(width: width, height: height)
                        .opacity(min(1, Double((amount - 0.12) / 0.55)))
                }

                if amount < 0.35 {
                    collapsedLens
                        .opacity(Double(1 - amount / 0.35))
                }
            }
            .frame(width: width, height: height)
            .scaleEffect(1 - model.flinch * 0.018, anchor: .top)
            .offset(y: model.flinch * 6)
        }
        .shadow(color: .black.opacity(0.55), radius: 18, y: 10)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(drag)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("luma.pill")
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                if !model.isDragging {
                    model.beginDrag()
                }
                model.updateDrag(translation: value.translation.height)
            }
            .onEnded { _ in
                model.endDrag()
            }
    }

    private var stem: some View {
        Capsule()
            .fill(Color.black)
            .frame(width: 16 + 8 * amount, height: 14)
            .offset(y: 4)
            .zIndex(1)
    }

    private func bodyPlastic(width: CGFloat, height: CGFloat, radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        bodyColor(highlight: 0.08),
                        bodyColor(highlight: 0),
                        bodyColor(highlight: -0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22 * amount),
                                Color.white.opacity(0.04 * amount)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
            .overlay(alignment: .bottom) {
                slot(width: width)
                    .opacity(Double(amount))
            }
    }

    private func innerContent(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                StatusChip(isLive: model.isLiveCapture)
                Spacer(minLength: 0)
                ShutterButton(
                    depressed: model.shutterDepressed,
                    enabled: model.canSnap
                ) {
                    model.snap()
                }
                .scaleEffect(0.72 + 0.28 * amount)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            ZStack {
                viewfinderWell
                ViewfinderView(
                    isLive: model.isLiveCapture,
                    session: model.capture.session,
                    time: model.sceneTime,
                    freezeFrame: model.ejecting?.photo.image
                )
                .padding(7)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                FlashBloom(isFlashing: model.isFlashing)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(7)
            }
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)

            Color.clear.frame(height: 22)
        }
        .frame(width: width, height: height)
    }

    private var viewfinderWell: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(red: 0.12, green: 0.11, blue: 0.1))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
            .padding(.horizontal, 10)
    }

    private var collapsedLens: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.25, green: 0.28, blue: 0.32),
                        Color(red: 0.05, green: 0.05, blue: 0.06)
                    ],
                    center: .center,
                    startRadius: 1,
                    endRadius: 10
                )
            )
            .frame(width: 18, height: 18)
            .overlay {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 4, height: 4)
                    .offset(x: -3, y: -3)
            }
    }

    private func slot(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color.black.opacity(0.72))
            .frame(width: width - 48, height: 6)
            .overlay {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            }
            .padding(.bottom, 14)
    }

    private func bodyColor(highlight: CGFloat) -> Color {
        Color(
            red: min(1, max(0, 0.03 + 0.91 * amount + highlight)),
            green: min(1, max(0, 0.03 + 0.87 * amount + highlight * 0.9)),
            blue: min(1, max(0, 0.03 + 0.80 * amount + highlight * 0.7))
        )
    }
}
