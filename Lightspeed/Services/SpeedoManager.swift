//
//  SpeedoManager.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import CoreLocation
import SwiftUI

@MainActor protocol SpeedoManager {
    typealias Speed = CLLocationSpeed
    typealias SpeedPublisher = Published<Speed?>.Publisher
    
    var speedPublisher: SpeedPublisher { get }
    var isRunning: Bool { get }
    
    func beginUpdates()
    func endUpdates()
}

class SpeedoManagerImpl: SpeedoManager, ObservableObject {
    
    private let manager: CLLocationManager

    @Published var speed: Speed?
    var speedPublisher: SpeedPublisher { $speed }
    
    private var count = 0
    private var shouldProcessUpdates: Bool = false
    
    var isRunning: Bool { shouldProcessUpdates }

    init() {
        self.manager = CLLocationManager()
    }

    func beginUpdates() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        print("Starting location updates")
        Task {
            do {
                shouldProcessUpdates = true
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !shouldProcessUpdates { break }
                    if let location = update.location {
                        speed = location.speed
                        count += 1
                        print("Speed \(count): \(speed ?? 0)")
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
        shouldProcessUpdates = false
    }
}

class SpeedoManagerPreviewMock: SpeedoManager {
    @Published var speed: Speed?
    var speedPublisher: SpeedPublisher { $speed }
    var isRunning: Bool = false
    func beginUpdates() {}
    func endUpdates() {}
}

