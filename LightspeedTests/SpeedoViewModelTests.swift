//
//  SpeedoViewModelTests.swift
//  LightspeedTests
//
//  Created by Liam on 15/06/2024.
//

import Combine
@testable import Lightspeed
import XCTest

final class SpeedoViewModelTests: XCTestCase {
    
    enum MockData {
        static let standardSequence: [SpeedData?] = [ // remember that raw speed data is in m/s
            nil,
            SpeedData(currentSpeed: 10.0, maximumSpeed: 10.0),
            SpeedData(currentSpeed: 20.0, maximumSpeed: 20.0),
            SpeedData(currentSpeed: 40.0, maximumSpeed: 40.0),
            SpeedData(currentSpeed: 60.0, maximumSpeed: 60.0), // this one should push up maximum
            SpeedData(currentSpeed: 45.0, maximumSpeed: 60.0)
        ]
    }
    
    var speedoManager: SpeedoManagerMock!
    var cancellables: [AnyCancellable] = []
    
    @MainActor override func setUp() {
        super.setUp()
        speedoManager = SpeedoManagerMock()
    }
    
    @MainActor override func tearDown() {
        cancellables.forEach { $0.cancel() }
    }

    @MainActor func buildSUT(
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
    
    @MainActor func testMapDataToInfo() throws {
        let sut = buildSUT()
        
        var values: [SpeedoViewInfo] = []
        sut.$info
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        sut.start()
        speedoManager.publish(data: MockData.standardSequence)
        
        XCTAssertTrue(speedoManager.beginUpdatesCalled)
        XCTAssertEqual(values, [
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // initial value
            .init(displaySpeed: "Unable to determine speed", dialProgress: 0.0, maximumSpeed: 50.0), // nil
            .init(displaySpeed: "36 km/h", dialProgress: 0.2, maximumSpeed: 50.0),
            .init(displaySpeed: "72 km/h", dialProgress: 0.4, maximumSpeed: 50.0),
            .init(displaySpeed: "144 km/h", dialProgress: 0.8, maximumSpeed: 50.0),
            .init(displaySpeed: "216 km/h", dialProgress: 1, maximumSpeed: 60.0),
            .init(displaySpeed: "162 km/h", dialProgress: 0.75, maximumSpeed: 60.0)
        ])
    }
    
    @MainActor func testMapDataToInfo_LocalisedFormatting() throws {
        let sut = buildSUT(
            speedFormatter: SpeedFormatter(locale: Locale(identifier: "en_GB"))
        )
        
        var values: [SpeedoViewInfo] = []
        sut.$info
            .sink { values.append($0) }
            .store(in: &cancellables)
        
        sut.start()
        speedoManager.publish(data: MockData.standardSequence)
        
        XCTAssertTrue(speedoManager.beginUpdatesCalled)
        XCTAssertEqual(values.map(\.displaySpeed), [
            "Unable to determine speed", // initial value
            "Unable to determine speed", // nil
            "22 mph",
            "45 mph",
            "89 mph",
            "134 mph",
            "101 mph"
        ])
    }
    
    @MainActor func testStartWhileRunning() {
        speedoManager.underlyingIsRunning = true
        let sut = buildSUT()
        sut.start()
        XCTAssertFalse(speedoManager.beginUpdatesCalled)
    }

}
