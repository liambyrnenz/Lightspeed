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
    var maximumSpeed: Double { get }
    
    func start()
    func stop()
}

class SpeedoViewModelImpl: SpeedoViewModel, ObservableObject {
    
    enum Constants {
        static let initialMaximumSpeed: Double = 50 // in m/sec == 180 km/h
    }
    
    @Published var displaySpeed: String = Strings.Speedo.unableToDetermine
    @Published var dialProgress: Double = 0
    @Published var maximumSpeed: Double = Constants.initialMaximumSpeed
    
    private let speedoManager: SpeedoManager
    
    init(speedoManager: SpeedoManager) {
        self.speedoManager = speedoManager
    }
    
    func start() {
        if speedoManager.isRunning {
            return
        }
        
        speedoManager.beginUpdates()
        let sharedPublisher = speedoManager.speedDataPublisher.share()
        sharedPublisher
            .map { speedData in
                self.formatSpeed(speedData?.currentSpeed)
            }
            .assign(to: &$displaySpeed)
        sharedPublisher
            .map { speedData in
                let progress = ((speedData?.currentSpeed ?? 0) / self.maximumSpeed)
                return min(max(0, progress), 1)
            }
            .assign(to: &$dialProgress)
        sharedPublisher
            .map { speedData in
                max(speedData?.maximumSpeed ?? 0, self.maximumSpeed)
            }
            .assign(to: &$maximumSpeed)
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
    var maximumSpeed: Double
    
    init(displaySpeed: String, dialProgress: Double, maximumSpeed: Double) {
        self.displaySpeed = displaySpeed
        self.dialProgress = dialProgress
        self.maximumSpeed = maximumSpeed
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
