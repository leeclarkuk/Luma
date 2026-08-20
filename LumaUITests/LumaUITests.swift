import XCTest

final class LumaUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testDragSnapEjectDevelopFocus() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-luma-fast-chem"]
        app.launch()

        let shots = ScreenshotWriter(test: self)

        let pill = element(app, "luma.pill")
        XCTAssertTrue(pill.waitForExistence(timeout: 8), "Camera pill should appear under the island")

        let start = pill.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let dest = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.64))
        start.press(forDuration: 0.08, thenDragTo: dest)

        let shutter = element(app, "luma.shutter")
        XCTAssertTrue(shutter.waitForExistence(timeout: 6), "Shutter should appear once the body is open")
        shots.capture(app, name: "01-drag")

        shutter.tap()

        let printCard = element(app, "luma.print.0")
        XCTAssertTrue(printCard.waitForExistence(timeout: 12), "Print should eject onto the shelf")
        shots.capture(app, name: "02-snap-eject")

        let developed = NSPredicate(format: "value == %@", "developed")
        expectation(for: developed, evaluatedWith: printCard)
        waitForExpectations(timeout: 8)
        shots.capture(app, name: "03-develop")

        printCard.tap()
        let focused = element(app, "luma.print.focused")
        XCTAssertTrue(focused.waitForExistence(timeout: 5), "Tapping a print should focus it")
        shots.capture(app, name: "04-focus")
    }

    private func element(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
