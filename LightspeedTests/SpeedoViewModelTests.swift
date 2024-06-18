//
//  SpeedoViewModelTests.swift
//  LightspeedTests
//
//  Created by Liam on 15/06/2024.
//

@testable import Lightspeed
import XCTest

final class SpeedoViewModelTests: XCTestCase {
    
    var speedoManager: SpeedoManagerMock!
    
    @MainActor override func setUp() {
        super.setUp()
        speedoManager = SpeedoManagerMock()
    }

    @MainActor func buildSUT() -> SpeedoViewModelImpl {
        SpeedoViewModelImpl(
            speedoManager: speedoManager
        )
    }
    
    @MainActor func testMapDataToInfo() throws {
        let mockData = [ // remember that raw speed data is in m/s
            SpeedData(currentSpeed: 10.0, maximumSpeed: 10.0),
            SpeedData(currentSpeed: 20.0, maximumSpeed: 20.0),
            SpeedData(currentSpeed: 40.0, maximumSpeed: 40.0),
            SpeedData(currentSpeed: 60.0, maximumSpeed: 60.0)
        ]
        
        let sut = buildSUT()
        
        var values: [SpeedoViewInfo] = []
        let publisher = sut.$info
            .dropFirst() // get rid of initial value
            .sink { values.append($0) }
        
        sut.start()
        speedoManager.publish(data: mockData)
        
        XCTAssertTrue(speedoManager.beginUpdatesCalled)
        XCTAssertEqual(values, [
            .init(displaySpeed: "36 km/h", dialProgress: 0.2, maximumSpeed: 50.0),
            .init(displaySpeed: "72 km/h", dialProgress: 0.4, maximumSpeed: 50.0),
            .init(displaySpeed: "144 km/h", dialProgress: 0.8, maximumSpeed: 50.0),
            .init(displaySpeed: "216 km/h", dialProgress: 1, maximumSpeed: 60.0)
        ])
    }

}
