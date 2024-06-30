//
//  SettingsView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers =  try? AuthenticationManager.shared.getProvider() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func updatePassword(currentPassword: String, newPassword: String, confirmPassword: String) throws {
        let authUser = Auth.auth().currentUser!
        
        guard let userEmail = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: currentPassword)
        
        authUser.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                //throw error for user authentication error
                print("unable to authenticate user")
            } else if confirmPassword != newPassword {
                //throw some error
                print("password not the same lmao")
            } else {
                authUser.updatePassword(to: newPassword) { error in
                    if let error = error {
                        //throw some error later on
                        print(error.localizedDescription)
                    } else {
                        //idk
                        print("success")
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var image: Image
    
    var body: some View {
        VStack {
            HStack{
                NavigationLink(destination: RootView()){
                    Text("Back")
                        .padding(10)
                }
                Spacer()
            }
            List {
                image
                if viewModel.authProviders.contains(.email) {
                    NavigationLink(destination: UpdatePasswordView()) {
                        Text("Update Password")
                    }
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
            }
            .navigationBarHidden(true)
        }
    }
}

/*
#Preview {
    SettingsView(showSignInView: .constant(false))
}
*/
