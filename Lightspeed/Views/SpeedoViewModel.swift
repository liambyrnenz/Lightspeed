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
            .map { speed in
                if let speed {
                    Strings.Speedo.kmhFormatted(speed.toKmh())
                } else {
                    Strings.Speedo.unableToDetermine
                }
            }
            .assign(to: &$displaySpeed)
    }
    
    func stop() {
        speedoManager.endUpdates()
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

extension SpeedoManager.Speed {
    
    func toKmh() -> Self {
        let kmSec = self / 1_000
        return kmSec * (60 * 60)
    }
    
}
