import XCTest

struct ScreenshotWriter {
    let test: XCTestCase

    func capture(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        test.add(attachment)

        let directory = Self.directory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("\(name).png")
        try? screenshot.pngRepresentation.write(to: url)
    }

    static var directory: URL {
        if let env = ProcessInfo.processInfo.environment["LUMA_SHOT_DIR"], !env.isEmpty {
            return URL(fileURLWithPath: env, isDirectory: true)
        }
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("LumaShots", isDirectory: true)
    }
}
