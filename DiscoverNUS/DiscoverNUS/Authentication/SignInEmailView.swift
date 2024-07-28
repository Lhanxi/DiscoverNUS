//
//  SignInEmailView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    @Published var alertMessage = ""

    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Your email or password is incorrect. Please try again."
            showAlert = true
            return
        }
        
        do {
            let _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        } catch {
            alertMessage = "Your email or password is incorrect. Please try again."
            showAlert = true
        }
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var navigateToForgotPassword = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20)  {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.headline)
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .foregroundColor(.gray)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.headline)
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .foregroundColor(.gray)
                        .autocapitalization(.none)
                }
                
                HStack {
                    NavigationLink(
                        destination: ForgotPasswordView(),
                        isActive: $navigateToForgotPassword) {
                        EmptyView()
                    }
                    .navigationBarHidden(true)
                    
                    Text("Forgot Password?")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .onTapGesture {
                            navigateToForgotPassword = true
                        }
                    Spacer()
                }
                
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            if !viewModel.showAlert {
                                showSignInView = false
                            }
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: 150)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In With Email")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            navigateToForgotPassword = false
        }
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
