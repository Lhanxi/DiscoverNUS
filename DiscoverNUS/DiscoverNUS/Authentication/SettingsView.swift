//
//  SettingsView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func updateEmail() async throws{
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws{
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let _ = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        
        let password = ""
        
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            emailSection
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}


extension SettingsView {
    private var emailSection: some View {
        Section {
            
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED")
                    } catch {
                        print(error)
                    }
                }
            }

            
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
}
