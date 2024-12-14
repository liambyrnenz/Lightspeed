//
//  SpeedoViewModelTests.swift
//  LightspeedTests
//
//  Created by Liam on 15/06/2024.
//

import Foundation
@testable import Lightspeed
import Testing
import XCTest

final class SpeedoViewModelTests {

    enum MockData {
        static let standardSequence: [SpeedData] = [ // remember that raw speed data is in m/s
            SpeedData(currentSpeed: 10.0, maximumSpeed: 10.0),
            SpeedData(currentSpeed: 20.0, maximumSpeed: 20.0),
            SpeedData(currentSpeed: nil, maximumSpeed: 20.0),
            SpeedData(currentSpeed: 40.0, maximumSpeed: 40.0),
            SpeedData(currentSpeed: 60.0, maximumSpeed: 60.0), // this one should push up maximum
            SpeedData(currentSpeed: 45.0, maximumSpeed: 60.0)
        ]
    }

    var speedoManagerMock: SpeedoManagerMock!
    var infoCollector: ObservationCollector<SpeedoViewInfo>!

    init() {
        speedoManagerMock = SpeedoManagerMock()
        infoCollector = ObservationCollector()
    }

    func buildSUT(
        speedFormatter: SpeedFormatter = .init(),
        initialMaximumSpeed: Double = SpeedoViewModelImpl.Constants.initialMaximumSpeed
    ) -> SpeedoViewModelImpl {
        SpeedoViewModelImpl(
            speedoManager: speedoManagerMock,
            speedFormatter: speedFormatter,
            initialMaximumSpeed: initialMaximumSpeed
        )
    }

    // MARK: - Tests

    @Test
    func mapDataToInfo() async {
        let mockData = MockData.standardSequence
        let sut = buildSUT()

        let expectation = XCTestExpectation(description: "SpeedoViewInfo values should be populated")
        infoCollector.runObservation(on: sut.info, expectation: expectation, valuesExpectedCount: mockData.count)

        speedoManagerMock.load(data: mockData)
        await sut.start()

        _ = await XCTWaiter.fulfillment(of: [expectation], timeout: 5)

        #expect(sut.isRunning)
        #expect(infoCollector.values == [
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // initial value
            .init(displaySpeed: "36 km/h", dialProgress: 0.2, maximumSpeed: 50.0),
            .init(displaySpeed: "72 km/h", dialProgress: 0.4, maximumSpeed: 50.0),
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // nil
            .init(displaySpeed: "144 km/h", dialProgress: 0.8, maximumSpeed: 50.0),
            .init(displaySpeed: "216 km/h", dialProgress: 1, maximumSpeed: 60.0),
            .init(displaySpeed: "162 km/h", dialProgress: 0.75, maximumSpeed: 60.0)
        ])
    }

    @Test
    func mapDataToInfo_LocalisedFormatting() async {
        let mockData = MockData.standardSequence
        let sut = buildSUT(
            speedFormatter: SpeedFormatter(locale: Locale(identifier: "en_GB"))
        )

        let expectation = XCTestExpectation(description: "SpeedoViewInfo values should be populated")
        infoCollector.runObservation(on: sut.info, expectation: expectation, valuesExpectedCount: mockData.count)

        speedoManagerMock.load(data: mockData)
        await sut.start()

        _ = await XCTWaiter.fulfillment(of: [expectation], timeout: 5)

        #expect(sut.isRunning)
        #expect(infoCollector.values.map(\.displaySpeed) == [
            "Unable to determine speed", // initial value
            "22 mph",
            "45 mph",
            "Unable to determine speed", // nil
            "89 mph",
            "134 mph",
            "101 mph"
        ])
    }

}
