//
//  RootView.swift
//  TrackerApp
//
//  Switches between the sign-in flow and the main app based on session state.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Group {
            if auth.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager())
}
