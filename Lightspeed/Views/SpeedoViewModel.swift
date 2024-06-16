//
//  SpeedoViewModel.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

@MainActor protocol SpeedoViewModel: ObservableObject {
    var displaySpeed: String { get }
    
    func start()
    func stop()
}

class SpeedoViewModelImpl: SpeedoViewModel, ObservableObject {
    
    @Published var displaySpeed: String = Strings.Speedo.unableToDetermine
    
    private let speedoManager: SpeedoManager
    
    init(speedoManager: SpeedoManager) {
        self.speedoManager = speedoManager
    }
    
    func start() {
        speedoManager.beginUpdates()
        speedoManager.speedPublisher
            .map(formatSpeed(_:))
            .assign(to: &$displaySpeed)
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
    
    init(displaySpeed: String) {
        self.displaySpeed = displaySpeed
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
