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
    typealias SpeedDataPublisher = Published<SpeedData?>.Publisher
    
    var speedDataPublisher: SpeedDataPublisher { get }
    var isRunning: Bool { get }
    
    func beginUpdates()
    func endUpdates()
}

class SpeedoManagerImpl: SpeedoManager, ObservableObject {
    
    private let manager: CLLocationManager

    @Published var speedData: SpeedData?
    var speedDataPublisher: SpeedDataPublisher { $speedData }
    
    private var maximumSpeed: CLLocationSpeed?
    
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
                        maximumSpeed = max(maximumSpeed ?? 0, location.speed)
                        speedData = SpeedData(
                            currentSpeed: location.speed,
                            maximumSpeed: maximumSpeed
                        )
                        count += 1
                        print("Speed \(count): \(speedData?.currentSpeed ?? 0)")
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
    @Published var speedData: SpeedData?
    var speedDataPublisher: SpeedDataPublisher { $speedData }
    var isRunning: Bool = false
    func beginUpdates() {}
    func endUpdates() {}
}

