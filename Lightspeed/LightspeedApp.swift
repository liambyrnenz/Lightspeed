//
//  LightspeedApp.swift
//  Lightspeed
//
//  Created by Liam on 15/06/2024.
//

import SwiftUI

@main
struct AppLauncher {
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            LightspeedApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct LightspeedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}
