//
//  SignInView.swift
//  TrackerApp
//
//  Email OTP sign-in: enter email -> receive a 6-digit code -> enter code.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: AuthManager

    @State private var email = ""
    @State private var code = ""
    @State private var codeWasSent = false
    @FocusState private var fieldIsFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Habit Tracker")
                    .font(.largeTitle.bold())
                Text(codeWasSent ? "Enter the code we emailed you" : "Sign in with your email")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                if codeWasSent {
                    TextField("6-digit code", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        .focused($fieldIsFocused)
                } else {
                    TextField("you@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                        .focused($fieldIsFocused)
                }

                if let errorMessage = auth.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: primaryAction) {
                    if auth.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(codeWasSent ? "Verify" : "Send code")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(primaryActionDisabled)

                if codeWasSent {
                    Button("Use a different email") {
                        codeWasSent = false
                        code = ""
                        auth.errorMessage = nil
                    }
                    .font(.footnote)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .onAppear { fieldIsFocused = true }
    }

    private var primaryActionDisabled: Bool {
        if auth.isLoading { return true }
        return codeWasSent ? code.count < 6 : !email.contains("@")
    }

    private func primaryAction() {
        Task {
            if codeWasSent {
                await auth.verifyOTP(email: email, code: code)
            } else {
                await auth.sendOTP(email: email)
                if auth.errorMessage == nil {
                    codeWasSent = true
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthManager())
}
