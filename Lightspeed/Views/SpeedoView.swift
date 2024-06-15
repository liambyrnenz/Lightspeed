//
//  SpeedoView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct SpeedoView: View {
    @StateObject var viewModel: SpeedoViewModel
    
    var body: some View {
        Text(viewModel.displaySpeed)
            .onAppear {
                viewModel.start()
            }
    }
}

#Preview {
    SpeedoView(
        viewModel: SpeedoViewModel(
            speedoManager: SpeedoManagerPreviewMock()
        )
    )
}
