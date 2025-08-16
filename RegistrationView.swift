import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailForm = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @StateObject private var supabaseService = SupabaseService.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.brown)

                    Text("Join the Community")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Create your account to start earning points and connecting with fellow coffee lovers!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 30)

                if !showEmailForm {
                    // Social Login Options
                    VStack(spacing: 15) {
                        Button("Continue with Google") { registerWithGoogle() }
                            .socialButton(color: .red, icon: "globe")
                        Button("Continue with Apple") { registerWithApple() }
                            .socialButton(color: .black, icon: "applelogo")
                        Button("Continue with Email") { showEmailForm = true }
                            .socialButton(color: .brown, icon: "envelope")
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Button("Skip for now") { dismiss() }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 30)
                    
                } else {
                    // Email Registration Form
                    VStack(spacing: 20) {
                        VStack(spacing: 15) {
                            TextField("Full Name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)

                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal, 30)

                        Button(action: { Task { await registerWithEmail() } }) {
                            Text("Create Account")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(isFormValid ? Color.brown : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 30)

                        Button("Back to options") { showEmailForm = false }
                            .foregroundColor(.brown)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }

    // MARK: - Supabase Registration
    private func registerWithEmail() async {
        guard isFormValid else { return }
        if let communityId = appState.selectedCommunity?.id {
            if let user = try? await supabaseService.registerUser(
                name: name,
                email: email,
                password: password,
                communityId: communityId
            ) {
                appState.registerUser(user)
                dismiss()
            }
        }
    }

    private func registerWithGoogle() {
        // TODO: Implement Supabase Google Auth
    }

    private func registerWithApple() {
        // TODO: Implement Supabase Apple Auth
    }
}

// MARK: - Social Button Modifier
extension View {
    func socialButton(color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            self
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(color)
        .cornerRadius(12)
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AppState())
}
