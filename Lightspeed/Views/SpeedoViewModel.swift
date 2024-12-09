//
//  SpeedoViewModel.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

@MainActor protocol SpeedoViewModel: ObservableObject {
    var info: SpeedoViewInfo { get }

    func start()
    func stop()
}

class SpeedoViewModelImpl: SpeedoViewModel, ObservableObject {

    enum Constants {
        static let initialMaximumSpeed: Double = 50 // in m/sec == 180 km/h
    }

    @Published var info: SpeedoViewInfo

    private let speedoManager: SpeedoManager
    private let speedFormatter: SpeedFormatter

    init(
        speedoManager: SpeedoManager,
        speedFormatter: SpeedFormatter = .init(),
        initialMaximumSpeed: Double = Constants.initialMaximumSpeed
    ) {
        self.speedoManager = speedoManager
        self.speedFormatter = speedFormatter
        self.info = SpeedoViewInfo(
            displaySpeed: Strings.Speedo.unableToDetermine,
            dialProgress: 0,
            maximumSpeed: Constants.initialMaximumSpeed
        )
    }

    func start() {
        if speedoManager.isRunning {
            return
        }

        speedoManager.beginUpdates()
        speedoManager.speedDataPublisher
            .map { speedData in
                let displaySpeed = self.formatSpeed(speedData?.currentSpeed)
                let dialProportion = ((speedData?.currentSpeed ?? 0) / self.info.maximumSpeed)
                let dialProgress = min(max(0, dialProportion), 1)
                let maximumSpeed = max(speedData?.maximumSpeed ?? 0, self.info.maximumSpeed)
                return .init(
                    displaySpeed: displaySpeed,
                    dialProgress: dialProgress,
                    maximumSpeed: maximumSpeed
                )
            }
            .assign(to: &$info)
    }

    func stop() {
        speedoManager.endUpdates()
    }

    private func formatSpeed(_ speed: Double?) -> String {
        if let speed, speed >= 0 {
            speedFormatter.formatFrom(metersPerSecond: speed)
        } else {
            Strings.Speedo.unableToDetermine
        }
    }

}

class SpeedoViewModelPreviewMock: SpeedoViewModel {
    var info: SpeedoViewInfo

    init(info: SpeedoViewInfo) {
        self.info = info
    }

    func start() {}
    func stop() {}
}

struct SpeedFormatter {

    var locale = Locale.current

    func formatFrom(metersPerSecond: Double) -> String {
        Measurement<UnitSpeed>(value: metersPerSecond, unit: .metersPerSecond)
            .converted(to: UnitSpeed(forLocale: locale))
            .formatted(.measurement(width: .abbreviated).locale(locale))
    }

}
