//
//  SignUpEmailView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 2/6/24.
//

import SwiftUI

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var emailInUse = false
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "No email or password found."
            return
        }
        
        do {
            let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
        } catch {
            print(error)
            if let authError = error as NSError?, authError.code == 17007 {
                emailInUse = true
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SignUpEmailView: View {
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var navigateToRootView = false
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            Button {
                Task {
                    await viewModel.signUp()
                    if viewModel.emailInUse {
                        alertTitle = "Email In Use"
                        alertMessage = "This email is already in use."
                        showAlert = true
                    } else if let errorMessage = viewModel.errorMessage {
                        alertTitle = "Error"
                        alertMessage = errorMessage
                        showAlert = true
                    } else {
                        alertTitle = "Success"
                        alertMessage = "Account Created!"
                        showAlert = true
                        navigateToRootView = true
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: 150)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if navigateToRootView {
                            navigateToRootView = true
                        }
                    }
                )
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
        .background(
            NavigationLink(destination: RootView(), isActive: $navigateToRootView) {
                EmptyView()
            }
            .hidden() // Hide the link from the view hierarchy
        )
    }
}

#Preview {
    SignUpEmailView(showSignInView: .constant(false))
}
