//
//  SpeedoManagerMock.swift
//  LightspeedTests
//
//  Created by Liam on 18/06/2024.
//

import Combine
@testable import Lightspeed
import SwiftUI

class SpeedoManagerMock: SpeedoManager {
    
    var speedDataPublisher: SpeedDataPublisher
    private let speedDataPassthrough = PassthroughSubject<SpeedData?, Never>()
    
    init() {
        speedDataPublisher = speedDataPassthrough.eraseToAnyPublisher()
    }
    
    func publish(data: [SpeedData?]) {
        for datum in data {
            speedDataPassthrough.send(datum)
        }
        speedDataPassthrough.send(completion: .finished)
    }
    
    var isRunning: Bool { underlyingIsRunning }
    var underlyingIsRunning: Bool = false
    
    var beginUpdatesCallsCount: Int = 0
    var beginUpdatesCalled: Bool { beginUpdatesCallsCount > 0 }
    func beginUpdates() {
        beginUpdatesCallsCount += 1
    }
    
    var endUpdatesCallsCount: Int = 0
    var endUpdatesCalled: Bool { endUpdatesCallsCount > 0 }
    func endUpdates() {
        endUpdatesCallsCount += 1
    }
    
}
