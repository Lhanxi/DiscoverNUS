//
//  SignUpEmailView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 2/6/24.
//

import SwiftUI
import UIKit

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}

struct SignUpEmailView: View {
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
                
            } label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: 200)
                    .background(Color.orange)
                    .cornerRadius(20)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
    }
}

#Preview {
    SignUpEmailView(showSignInView: .constant(false))
}
