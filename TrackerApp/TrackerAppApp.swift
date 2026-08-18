//
//  TrackerAppApp.swift
//  TrackerApp
//
//  Created by Aishwarya Singh on 8/17/26.
//

import SwiftUI

@main
struct TrackerAppApp: App {
    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}
