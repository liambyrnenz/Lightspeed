//
//  ContentView.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SpeedoView(
            viewModel: SpeedoViewModelImpl(
                speedoManager: SpeedoManagerImpl()
            )
        )
    }
}

#Preview {
    ContentView()
}
