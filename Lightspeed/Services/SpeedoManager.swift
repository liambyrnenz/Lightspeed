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

@MainActor protocol SpeedoManager {
    var speedDataSequence: any AsyncSequence { get }
}

class SpeedoManagerImpl: SpeedoManager, ObservableObject {
    
    private let manager: CLLocationManager

    private var maximumSpeed: CLLocationSpeed?
    
    private var count = 0
    private var shouldProcessUpdates: Bool = false
    
    var isRunning: Bool { shouldProcessUpdates }

    init() {
        self.manager = CLLocationManager()
    }

    var speedDataSequence: any AsyncSequence {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        print("Starting location updates")
        return CLLocationUpdate.liveUpdates().map { @MainActor [weak self] update -> SpeedData? in
            guard let self, let location = update.location else { return nil }
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

    func endUpdates() {
        print("Stopping location updates")
        shouldProcessUpdates = false
    }
    
}

