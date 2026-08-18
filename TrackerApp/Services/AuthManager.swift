//
//  AuthManager.swift
//  TrackerApp
//
//  Handles the email OTP (6-digit code) sign-in flow and tracks the current
//  session. Session persistence across launches is handled automatically by
//  the Supabase SDK (stored in the Keychain).
//

import Combine
import Foundation
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseService.client

    var isSignedIn: Bool { session != nil }
    var userId: UUID? { session?.user.id }

    init() {
        Task { await observeAuthState() }
    }

    /// Listens for sign-in / sign-out / token-refresh events for the lifetime of the app.
    private func observeAuthState() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .initialSession, .signedIn, .tokenRefreshed:
                self.session = session
            case .signedOut:
                self.session = nil
            default:
                break
            }
        }
    }

    /// Step 1: request a 6-digit code be emailed to the user.
    func sendOTP(email: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await client.auth.signInWithOTP(email: email)
        } catch {
            errorMessage = "Couldn't send the code. Check the email address and try again."
        }
        isLoading = false
    }

    /// Step 2: verify the 6-digit code the user received.
    func verifyOTP(email: String, code: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await client.auth.verifyOTP(email: email, token: code, type: .email)
        } catch {
            errorMessage = "That code didn't work. Check it and try again."
        }
        isLoading = false
    }

    func signOut() async {
        try? await client.auth.signOut()
    }
}
