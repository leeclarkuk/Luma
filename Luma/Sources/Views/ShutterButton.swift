import SwiftUI

struct ShutterButton: View {
    var depressed: Bool
    var enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.45, green: 0.08, blue: 0.07))
                    .offset(y: depressed ? 1 : 3)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.32, blue: 0.28),
                                Color(red: 0.78, green: 0.12, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(Color(red: 0.45, green: 0.08, blue: 0.07), lineWidth: 3)
                            .padding(7)
                    }
                    .offset(y: depressed ? 2 : 0)
            }
            .frame(width: LumaLayout.shutterSize, height: LumaLayout.shutterSize)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.55)
        .accessibilityHidden(!enabled)
        .accessibilityIdentifier("luma.shutter")
        .accessibilityLabel("Shutter")
        .accessibilityAddTraits(.isButton)
    }
}
