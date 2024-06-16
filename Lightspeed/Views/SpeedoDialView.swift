//
//  SpeedoDialView.swift
//  Lightspeed
//
//  Created by Liam on 16/06/2024.
//

import SwiftUI

struct SpeedoDialView: View {
    struct Info {
        let size: CGFloat
        let progress: Double
    }
    
    var info: Info
    
    var dialProgressDegrees: Double {
        let minimumDegrees: Double = -45
        let maximumDegrees: Double = 225
        return minimumDegrees + (maximumDegrees - minimumDegrees) * info.progress
    }
    var needleSize: CGFloat { 0.02 * info.size }
    var needleFulcrumSize: CGFloat { 0.08 * info.size }
    
    var body: some View {
        ZStack {
            Circle()
            Rectangle()
                .fill(.red)
                .frame(width: info.size / 2, height: needleSize)
                .offset(x: -(info.size / 4))
                .rotationEffect(.degrees(dialProgressDegrees))
                .animation(.interpolatingSpring, value: dialProgressDegrees)
            Circle()
                .fill(.gray)
                .frame(width: needleFulcrumSize, height: needleFulcrumSize)
        }
        .frame(width: info.size, height: info.size)
    }
}

#Preview {
    SpeedoDialView(
        info: .init(
            size: 300,
            progress: 0
        )
    )
}
