import SwiftUI

struct ContentView: View {
    @Bindable var model: CameraModel

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    Color.black.ignoresSafeArea()
                    ShakeCatcher()
                        .allowsHitTesting(false)

                    PhotoShelfView(model: model)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 24)

                    if let ejecting = model.ejecting {
                        ejectingPrint(ejecting, in: geo)
                    }

                    CameraBodyView(model: model)
                        .padding(.top, LumaLayout.islandOffset)

                    if let photo = model.focusedPhoto {
                        FocusedPrintView(photo: photo, model: model)
                    }

                    if let message = model.saveMessage {
                        saveToast(message)
                    }
                }
                .onChange(of: timeline.date) { _, date in
                    model.pulse(at: date)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(false)
        .environment(model)
        .onAppear { model.start() }
    }

    @ViewBuilder
    private func ejectingPrint(_ ejecting: EjectingPrint, in geo: GeometryProxy) -> some View {
        let progress = ejecting.progress
        let bodyHeight = LumaLayout.bodyHeight(model.layoutAmount)
        let startY = LumaLayout.islandOffset + bodyHeight * 0.42
        let slotY = LumaLayout.islandOffset + bodyHeight - 6
        let shelfY = geo.size.height - 168
        let y: CGFloat = {
            if progress < 0.32 {
                let t = progress / 0.32
                return startY + (slotY - startY) * t
            }
            let t = (progress - 0.32) / 0.68
            let eased = 1 - CGFloat(pow(1 - Double(t), 2.4))
            return slotY + (shelfY - slotY) * eased
        }()
        let scale = 0.70 + 0.30 * min(1, progress / 0.42)
        let rotation = Angle.degrees(Double(4 * (1 - progress)))

        InstantPrintCard(photo: ejecting.photo, compact: false)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .position(x: geo.size.width / 2, y: y)
            .allowsHitTesting(false)
    }

    private func saveToast(_ message: String) -> some View {
        Text(message)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.12), in: Capsule())
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 88)
            .transition(.opacity)
    }
}
