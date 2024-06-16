//
//  SpeedoView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct SpeedoView<ViewModel: SpeedoViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Text(viewModel.displaySpeed)
            .font(.largeTitle)
            .bold()
            .onAppear {
                viewModel.start()
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
