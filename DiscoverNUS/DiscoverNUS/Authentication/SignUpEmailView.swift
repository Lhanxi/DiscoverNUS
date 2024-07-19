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
    @State var completedSignUp = false
    @State var navigateBack = false
    
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
                     .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
             }
             
             VStack(alignment: .leading, spacing: 5) {
                 Text("Password")
                     .font(.headline)
                 SecureField("Password", text: $viewModel.password)
                     .padding()
                     .background(Color.gray.opacity(0.4))
                     .cornerRadius(10)
                     .foregroundColor(.gray)
                     .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
             }
            
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        self.completedSignUp = true
                    } catch {
                        print(error)
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
