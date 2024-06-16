//
//  SpeedoView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct SpeedoView<ViewModel: SpeedoViewModel>: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewModel: ViewModel
    
    var displaySpeedFont: Font {
        if viewModel.displaySpeed == Strings.Speedo.unableToDetermine {
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
                progress: viewModel.dialProgress,
                maximumSpeed: viewModel.maximumSpeed
            ))
            Spacer()
                .frame(height: 16)
            Text(viewModel.displaySpeed)
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
        viewModel: SpeedoViewModelPreviewMock(
            displaySpeed: SpeedFormatter.formatFrom(
                metersPerSecond: randomMetersPerSecond
            ),
            dialProgress: randomMetersPerSecond / maxMetersPerSecond,
            maximumSpeed: maxMetersPerSecond
        )
    )
}
