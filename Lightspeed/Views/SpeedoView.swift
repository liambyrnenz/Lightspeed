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
    
    var body: some View {
        VStack {
            SpeedoDialView(info: .init(
                size: 150,
                progress: viewModel.dialProgress
            ))
            Spacer()
                .frame(height: 16)
            Text(viewModel.displaySpeed)
                .font(displaySpeedFont)
                .bold()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active, .inactive:
                viewModel.start()
            case .background:
                viewModel.stop()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    let randomMetersPerSecond = Double.random(
        in: 1...27 // 0-100 km/h
    )
    
    return SpeedoView(
        viewModel: SpeedoViewModelPreviewMock(
            displaySpeed: SpeedFormatter.formatFrom(
                metersPerSecond: randomMetersPerSecond
            ),
            dialProgress: randomMetersPerSecond / 27
        )
    )
}
