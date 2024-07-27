//
//  AuthenticationView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws{
        let helper = SignInGoogle()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
}

struct AuthenticationView: View {
    @State private var navigateBack = false
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack(spacing: 0) {
            
            Image(.appLogo)
                .resizable(capInsets: EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding()
            
            Image(.slogan)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding()
                .offset(y: -30)
            
            VStack(spacing: 20) {
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: 250)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
                
                NavigationLink {
                    SignUpEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(Color.orange)
                        .frame(height: 55)
                        .frame(maxWidth: 250)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                }
                HStack(spacing:20) {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .icon, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                self.navigateBack = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.signInApple()
                                self.navigateBack = true
                            } catch {
                                print(error)
                            }
                        }
                    }) {
                        Image(systemName: "apple.logo")
                            .foregroundColor(Color.black)
                            .frame(width: 40, height: 40)
                            .background(
                                ZStack {
                                    Color.white
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 1, y: 1)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 4)
                    }
                }
            }

            
            Spacer()
            
            NavigationLink(destination: RootView(), isActive: $navigateBack){}.navigationBarHidden(true)
        }
        .padding()
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
