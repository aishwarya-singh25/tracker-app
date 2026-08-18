//
//  ProfileView.swift
//  TrackerApp
//

import Auth
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    LabeledContent("Email", value: auth.session?.user.email ?? "—")
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        Task { await auth.signOut() }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
