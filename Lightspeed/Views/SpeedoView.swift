//
//  SpeedoView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct SpeedoViewInfo: Equatable {
    var displaySpeed: String
    var displaySpeedValue: Double
    var dialProgress: Double
    var maximumSpeed: Double
}

struct SpeedoView<ViewModel: SpeedoViewModel>: View {

    @Environment(\.scenePhase) var scenePhase

    var viewModel: ViewModel
    var info: SpeedoViewInfo { viewModel.info }

    var displaySpeedFont: Font {
        if info.displaySpeed == Strings.Speedo.unableToDetermine {
            .title3
        } else {
            .largeTitle
        }
    }

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active, .inactive:
            Task {
                await viewModel.start()
            }
        case .background:
            viewModel.stop()
        @unknown default:
            break
        }
    }

    var body: some View {
        VStack {
            SpeedoDialView(info: .init(
                size: 150,
                progress: info.dialProgress,
                maximumSpeed: info.maximumSpeed
            ))
            Spacer()
                .frame(height: 16)
            Text(info.displaySpeed)
                .frame(minHeight: 48)
                .font(displaySpeedFont)
                .bold()
                .contentTransition(.numericText(value: info.displaySpeedValue))
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
}

#Preview {
    let maxMetersPerSecond: Double = 27 // 100 km/h
    let randomMetersPerSecond = Double.random(
        in: 1...maxMetersPerSecond
    )
    let speed = SpeedFormatter().formatFrom(
        metersPerSecond: randomMetersPerSecond
    )

    return SpeedoView(
        viewModel: SpeedoViewModelPreviewMock(info: .init(
            displaySpeed: speed.display,
            displaySpeedValue: speed.value,
            dialProgress: randomMetersPerSecond / maxMetersPerSecond,
            maximumSpeed: maxMetersPerSecond
        ))
    )
}
