import SwiftUI

struct FlashBloom: View {
    var isFlashing: Bool

    var body: some View {
        Color.white
            .opacity(isFlashing ? 0.92 : 0)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }
}
