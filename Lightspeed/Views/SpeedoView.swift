//
//  SpeedoView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct SpeedoViewInfo {
    var displaySpeed: String
    var dialProgress: Double
    var maximumSpeed: Double
}

struct SpeedoView<ViewModel: SpeedoViewModel>: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel: ViewModel
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
            viewModel.start()
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
    
    return SpeedoView(
        viewModel: SpeedoViewModelPreviewMock(info: .init(
            displaySpeed: SpeedFormatter.formatFrom(
                metersPerSecond: randomMetersPerSecond
            ),
            dialProgress: randomMetersPerSecond / maxMetersPerSecond,
            maximumSpeed: maxMetersPerSecond
        ))
    )
}
