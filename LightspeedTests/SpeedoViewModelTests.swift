//
//  SpeedoViewModelTests.swift
//  LightspeedTests
//
//  Created by Liam on 15/06/2024.
//

@testable import Lightspeed
import XCTest

final class SpeedoViewModelTests: XCTestCase {

    enum MockData {
        static let standardSequence: [SpeedData?] = [ // remember that raw speed data is in m/s
            SpeedData(currentSpeed: 10.0, maximumSpeed: 10.0),
            SpeedData(currentSpeed: 20.0, maximumSpeed: 20.0),
            SpeedData(currentSpeed: nil, maximumSpeed: 20.0),
            SpeedData(currentSpeed: 40.0, maximumSpeed: 40.0),
            SpeedData(currentSpeed: 60.0, maximumSpeed: 60.0), // this one should push up maximum
            SpeedData(currentSpeed: 45.0, maximumSpeed: 60.0)
        ]
    }

    var speedoManager: SpeedoManagerMock!
    var infoCollector: ObservationCollector<SpeedoViewInfo>!

    override func setUp() {
        super.setUp()
        speedoManager = SpeedoManagerMock()
        infoCollector = ObservationCollector()
    }

    func buildSUT(
        speedFormatter: SpeedFormatter = .init(),
        initialMaximumSpeed: Double = SpeedoViewModelImpl.Constants.initialMaximumSpeed
    ) -> SpeedoViewModelImpl {
        SpeedoViewModelImpl(
            speedoManager: speedoManager,
            speedFormatter: speedFormatter,
            initialMaximumSpeed: initialMaximumSpeed
        )
    }

    // MARK: - Tests

    func testMapDataToInfo() async {
        let mockData = MockData.standardSequence
        let sut = buildSUT()

        let expectation = expectation(description: "SpeedoViewInfo values should be populated")
        infoCollector.runObservation(on: sut.info, expectation: expectation, valuesExpectedCount: mockData.count)

        speedoManager.publish(data: mockData)
        await sut.start()

        await fulfillment(of: [expectation], timeout: 5)

//        XCTAssertTrue(speedoManager.beginUpdatesCalled)
        XCTAssertEqual(infoCollector.values, [
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // initial value
            .init(displaySpeed: "36 km/h", dialProgress: 0.2, maximumSpeed: 50.0),
            .init(displaySpeed: "72 km/h", dialProgress: 0.4, maximumSpeed: 50.0),
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // nil
            .init(displaySpeed: "144 km/h", dialProgress: 0.8, maximumSpeed: 50.0),
            .init(displaySpeed: "216 km/h", dialProgress: 1, maximumSpeed: 60.0),
            .init(displaySpeed: "162 km/h", dialProgress: 0.75, maximumSpeed: 60.0)
        ])
    }

    func testMapDataToInfo_LocalisedFormatting() async {
        let mockData = MockData.standardSequence
        let sut = buildSUT(
            speedFormatter: SpeedFormatter(locale: Locale(identifier: "en_GB"))
        )

        let expectation = expectation(description: "SpeedoViewInfo values should be populated")
        infoCollector.runObservation(on: sut.info, expectation: expectation, valuesExpectedCount: mockData.count)

        speedoManager.publish(data: mockData)
        await sut.start()

        await fulfillment(of: [expectation], timeout: 5)

//        XCTAssertTrue(speedoManager.beginUpdatesCalled)
        XCTAssertEqual(infoCollector.values.map(\.displaySpeed), [
            "Unable to determine speed", // initial value
            "22 mph",
            "45 mph",
            "Unable to determine speed", // nil
            "89 mph",
            "134 mph",
            "101 mph"
        ])
    }

//    func testStartWhileRunning() {
//        speedoManager.underlyingIsRunning = true
//        let sut = buildSUT()
//        sut.start()
//        XCTAssertFalse(speedoManager.beginUpdatesCalled)
//    }

}
