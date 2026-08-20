import AVFoundation
import SwiftUI

struct ViewfinderView: View {
    var isLive: Bool
    var session: AVCaptureSession?
    var time: TimeInterval
    var freezeFrame: UIImage?

    var body: some View {
        ZStack {
            Color.black
            if let freezeFrame {
                Image(uiImage: freezeFrame)
                    .resizable()
                    .scaledToFill()
            } else if isLive, let session {
                CameraPreviewView(session: session)
            } else {
                DemoSceneView(time: time)
            }
        }
        .clipped()
    }
}
