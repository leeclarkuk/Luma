import SwiftUI

struct FocusedPrintView: View {
    var photo: InstantPhoto
    @Bindable var model: CameraModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()
                .onTapGesture { model.dismissFocus() }

            VStack(spacing: 22) {
                InstantPrintCard(photo: photo, compact: false)
                    .accessibilityIdentifier("luma.print.focused")
                    .onTapGesture { model.dismissFocus() }

                Button("Save to Photos") {
                    model.saveFocused()
                }
                .font(.headline)
                .foregroundStyle(.black)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(Color(red: 0.96, green: 0.93, blue: 0.86), in: Capsule())
                .accessibilityIdentifier("luma.save")
            }
        }
        .accessibilityAddTraits(.isModal)
    }
}
