//
//  SpeedoManager.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import CoreLocation
import SwiftUI

struct SpeedData {
    let currentSpeed: CLLocationSpeed?
    let maximumSpeed: CLLocationSpeed?
}

protocol SpeedoManager {
    var speedDataSequence: any AsyncSequence { get }
}

class SpeedoManagerImpl: SpeedoManager {

    private let manager: CLLocationManager

    private var maximumSpeed: CLLocationSpeed?
    private var count = 0

    init() {
        self.manager = CLLocationManager()
    }

    var speedDataSequence: any AsyncSequence {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        return CLLocationUpdate.liveUpdates().map { [weak self] update -> SpeedData in
            guard let self, let location = update.location else {
                // returns nil wrapped within a SpeedData so that nil can still be used to signal end of sequence
                return SpeedData(currentSpeed: nil, maximumSpeed: self?.maximumSpeed)
            }
            maximumSpeed = max(maximumSpeed ?? 0, location.speed)
            let speedData = SpeedData(
                currentSpeed: location.speed,
                maximumSpeed: maximumSpeed
            )
            count += 1
            print("Speed \(count): \(speedData.currentSpeed ?? 0)")
            return speedData
        }
    }

}
