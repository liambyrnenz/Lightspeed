//
//  SpeedoManagerMock.swift
//  LightspeedTests
//
//  Created by Liam on 18/06/2024.
//

@testable import Lightspeed
import SwiftUI

class SpeedoManagerMock: SpeedoManager {

    var speedDataSequence: any AsyncSequence = AsyncStream<SpeedData?>(unfolding: { nil })

    func publish(data: [SpeedData?]) {
        speedDataSequence = AsyncStream<SpeedData?> { continuation in
            for datum in data {
                continuation.yield(datum)
            }
            continuation.finish()
        }
    }

}
