//
//  SpeedoViewModel.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

@MainActor protocol SpeedoViewModel: ObservableObject {
    var displaySpeed: String { get }
    var dialProgress: Double { get }
    
    func start()
    func stop()
}

class SpeedoViewModelImpl: SpeedoViewModel, ObservableObject {
    
    @Published var displaySpeed: String = Strings.Speedo.unableToDetermine
    @Published var dialProgress: Double = 0
    
    private let speedoManager: SpeedoManager
    
    init(speedoManager: SpeedoManager) {
        self.speedoManager = speedoManager
    }
    
    func start() {
        if speedoManager.isRunning {
            return
        }
        
        speedoManager.beginUpdates()
        let sharedSpeedPublisher = speedoManager.speedPublisher.share()
        sharedSpeedPublisher
            .map(formatSpeed(_:))
            .assign(to: &$displaySpeed)
        sharedSpeedPublisher
            .map { speed in
                let progress = ((speed ?? 0) / 89) // 320 km/h
                return min(max(0, progress), 1)
            }
            .assign(to: &$dialProgress)
    }
    
    func stop() {
        speedoManager.endUpdates()
    }
    
    private func formatSpeed(_ speed: Double?) -> String {
        if let speed, speed >= 0 {
            SpeedFormatter.formatFrom(metersPerSecond: speed)
        } else {
            Strings.Speedo.unableToDetermine
        }
    }
    
}

class SpeedoViewModelPreviewMock: SpeedoViewModel {
    var displaySpeed: String
    var dialProgress: Double
    
    init(displaySpeed: String, dialProgress: Double) {
        self.displaySpeed = displaySpeed
        self.dialProgress = dialProgress
    }
    
    func start() {}
    func stop() {}
}

enum SpeedFormatter {
    
    static func formatFrom(metersPerSecond: Double) -> String {
        Measurement<UnitSpeed>(value: metersPerSecond, unit: .metersPerSecond)
            .converted(to: UnitSpeed(forLocale: Locale.current))
            .formatted()
    }
    
}
