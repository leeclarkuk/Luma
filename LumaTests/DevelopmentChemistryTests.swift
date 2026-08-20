import XCTest
@testable import Luma

final class DevelopmentChemistryTests: XCTestCase {
    func testEaseBounds() {
        XCTAssertEqual(DevelopmentChemistry.ease(0), 0, accuracy: 0.0001)
        XCTAssertEqual(DevelopmentChemistry.ease(1), 1, accuracy: 0.0001)
        XCTAssertGreaterThan(DevelopmentChemistry.ease(0.5), 0.4)
        XCTAssertLessThan(DevelopmentChemistry.ease(0.5), 0.6)
    }

    func testLookResolvesFromMilkyGreenToClear() {
        let start = DevelopmentChemistry.look(progress: 0)
        let end = DevelopmentChemistry.look(progress: 1)
        XCTAssertLessThan(start.saturation, end.saturation)
        XCTAssertGreaterThan(start.blur, end.blur)
        XCTAssertGreaterThan(start.brightness, end.brightness)
        XCTAssertGreaterThan(start.greenCast, end.greenCast)
        XCTAssertEqual(end.greenCast, 0, accuracy: 0.0001)
        XCTAssertEqual(end.blur, 0, accuracy: 0.0001)
    }

    func testAdvanceAndShake() {
        let next = DevelopmentChemistry.advance(progress: 0, dt: 1, duration: 10, shaking: false)
        XCTAssertEqual(next, 0.1, accuracy: 0.0001)
        let shaken = DevelopmentChemistry.advance(progress: 0, dt: 1, duration: 10, shaking: true)
        XCTAssertGreaterThan(shaken, next)
        XCTAssertEqual(DevelopmentChemistry.applyShake(0.5), 0.64, accuracy: 0.0001)
        XCTAssertEqual(DevelopmentChemistry.applyShake(0.99), 1, accuracy: 0.0001)
    }
}
