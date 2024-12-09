//
//  SpeedoDialView.swift
//  Lightspeed
//
//  Created by Liam on 16/06/2024.
//

import SwiftUI

struct SpeedoDialViewInfo {
    let size: CGFloat
    let progress: Double
    let maximumSpeed: Double
}

struct SpeedoDialView: View {

    var info: SpeedoDialViewInfo

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
                .animation(.easeInOut(duration: 1), value: dialProgressDegrees)
            Circle()
                .fill(.gray)
                .frame(width: needleFulcrumSize, height: needleFulcrumSize)
            Text(SpeedFormatter().formatFrom(metersPerSecond: info.maximumSpeed))
                .font(.system(size: info.size / 15))
                .offset(x: (info.size / 2) - 4, y: (info.size / 2) - 4)
        }
        .frame(width: info.size, height: info.size)
    }
}

#Preview {
    SpeedoDialView(
        info: .init(
            size: 300,
            progress: 0.33,
            maximumSpeed: 27
        )
    )
}
