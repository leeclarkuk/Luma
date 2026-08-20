import SwiftUI

struct StatusChip: View {
    var isLive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isLive ? Color.green : Color.orange)
                .frame(width: 7, height: 7)
                .shadow(color: (isLive ? Color.green : Color.orange).opacity(0.8), radius: 3)
            Text(isLive ? "LIVE" : "DEMO")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(0.6)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.black.opacity(0.38), in: Capsule())
        .accessibilityIdentifier("luma.status")
        .accessibilityLabel(isLive ? "Live camera" : "Demo scene")
    }
}
