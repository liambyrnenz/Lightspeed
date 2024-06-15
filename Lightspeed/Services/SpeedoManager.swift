//
//  SpeedoManager.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import CoreLocation
import SwiftUI

@MainActor protocol SpeedoManager {
    func beginUpdates()
    func endUpdates()
}

class SpeedoManagerImpl: SpeedoManager, ObservableObject {
    
    typealias Speed = CLLocationSpeed
    
    private let manager: CLLocationManager

    @Published var speed: Speed?
    @Published var isStationary = false
    
    private var count = 0
    private var shouldProcessUpdates: Bool = false

    init() {
        self.manager = CLLocationManager()
    }

    func beginUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
        print("Starting location updates")
        Task {
            do {
                self.shouldProcessUpdates = true
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !self.shouldProcessUpdates { break }
                    if let location = update.location {
                        self.speed = location.speed
                        self.isStationary = update.isStationary
                        self.count += 1
                        print("Speed \(self.count): \(self.speed ?? 0)")
                    }
                }
            } catch {
                print("Could not start location updates")
            }
            return
        }
    }

    func endUpdates() {
        print("Stopping location updates")
        self.shouldProcessUpdates = false
    }
}

class SpeedoManagerPreviewMock: SpeedoManager {
    func beginUpdates() {}
    func endUpdates() {}
}
