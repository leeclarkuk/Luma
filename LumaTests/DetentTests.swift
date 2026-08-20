import XCTest
@testable import Luma

final class DetentTests: XCTestCase {
    func testNearestStops() {
        XCTAssertEqual(Detents.nearest(0.01), 0, accuracy: 0.0001)
        XCTAssertEqual(Detents.nearest(0.2), 0.28, accuracy: 0.0001)
        XCTAssertEqual(Detents.nearest(0.5), 0.62, accuracy: 0.0001)
        XCTAssertEqual(Detents.nearest(0.9), 1.0, accuracy: 0.0001)
    }

    func testRubberBandResistsBeyondEnds() {
        XCTAssertEqual(Detents.rubber(0.5), 0.5, accuracy: 0.0001)
        XCTAssertLessThan(Detents.rubber(-0.5), 0)
        XCTAssertGreaterThan(Detents.rubber(-0.5), -0.5)
        XCTAssertGreaterThan(Detents.rubber(1.5), 1)
        XCTAssertLessThan(Detents.rubber(1.5), 1.5)
    }

    func testIndexTracksStops() {
        XCTAssertEqual(Detents.index(for: 0), 0)
        XCTAssertEqual(Detents.index(for: 0.28), 1)
        XCTAssertEqual(Detents.index(for: 0.62), 2)
        XCTAssertEqual(Detents.index(for: 1), 3)
    }
}
