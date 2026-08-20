import SwiftUI

struct PhotoShelfView: View {
    @Bindable var model: CameraModel

    var body: some View {
        let photos = model.shelfPhotos
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -36) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    InstantPrintCard(photo: photo, compact: true, index: index)
                        .rotationEffect(.degrees(index.isMultiple(of: 2) ? -4 : 5))
                        .zIndex(Double(photos.count - index))
                        .onTapGesture {
                            model.focus(photo)
                        }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
        }
        .frame(height: photos.isEmpty ? 0 : 180)
        .opacity(photos.isEmpty ? 0 : 1)
        .accessibilityIdentifier("luma.shelf")
        .accessibilityLabel("Photo shelf")
    }
}
