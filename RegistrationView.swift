import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailForm = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                        // Google Sign Up
                        Button(action: {
                            registerWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title2)
                                Text("Continue with Google")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        
                        // Apple Sign Up
                        Button(action: {
                            registerWithApple()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.title2)
                                Text("Continue with Apple")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.black)
                            .cornerRadius(12)
                        }
                        
                        // Email Sign Up
                        Button(action: {
                            showEmailForm = true
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                    .font(.title2)
                                Text("Continue with Email")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.brown)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Skip Option
                    Button("Skip for now") {
                        dismiss()
                    }
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
                        
                        Button(action: {
                            registerWithEmail()
                        }) {
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
                        
                        Button("Back to options") {
                            showEmailForm = false
                        }
                        .foregroundColor(.brown)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
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
    
    private func registerWithGoogle() {
        // TODO: Implement Google OAuth with Supabase
        print("Google registration not yet implemented")
    }
    
    private func registerWithApple() {
        // TODO: Implement Apple Sign In with Supabase
        print("Apple registration not yet implemented")
    }
    
    private func registerWithEmail() {
        guard isFormValid else { return }
        
        Task {
            await appState.registerUser(name: name, email: email, password: password)
            if appState.currentUser != nil {
                dismiss()
            }
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AppState())
}