//
//  Strings.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

enum Strings {
    enum Speedo {
        static func kmhFormatted(_ kmh: Double) -> String {
            "\(kmh)km/h"
        }
        
        static let unableToDetermine = "Unable to determine speed"
    }
}
