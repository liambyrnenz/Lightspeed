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
            .onAppear {
                viewModel.start()
            }
    }
}

#Preview {
    SpeedoView(
        viewModel: SpeedoViewModelPreviewMock(
            displaySpeed: Strings.Speedo.kmhFormatted(
                Double.random(
                    in: 0...100
                )
            )
        )
    )
}
