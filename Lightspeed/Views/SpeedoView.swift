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
    
    var body: some View {
        Text(viewModel.displaySpeed)
            .font(.largeTitle)
            .bold()
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
    SpeedoView(
        viewModel: SpeedoViewModelPreviewMock(
            displaySpeed: SpeedFormatter.formatFrom(
                metersPerSecond: Double.random(
                    in: 1...27
                )
            )
        )
    )
}
