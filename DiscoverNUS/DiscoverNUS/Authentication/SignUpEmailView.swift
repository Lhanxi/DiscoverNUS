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
    @Published var errorMessage: String? // New property for error messages
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "No email or password found."
            return
        }
        
        do {
            let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
        } catch {
            if let authError = error as NSError?, authError.code == 17007 {
                errorMessage = "This email is already in use."
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SignUpEmailView: View {
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State var completedSignUp = false
    @State var navigateBack = false
    @State var showAlert = false
    
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
                    if viewModel.errorMessage != nil {
                        showAlert = true
                    } else {
                        completedSignUp = true
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
            .alert(isPresented: $completedSignUp) {
                Alert(
                    title: Text("Success"),
                    message: Text("Account Created!"),
                    dismissButton: .default(Text("OK")){
                        self.navigateBack = true
                    })
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")))
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
        
        NavigationLink(destination: RootView(), isActive: $navigateBack){}
    }
}

#Preview {
    SignUpEmailView(showSignInView: .constant(false))
}
