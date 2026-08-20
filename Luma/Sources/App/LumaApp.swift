import SwiftUI

@main
struct LumaApp: App {
    @State private var model = CameraModel()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
