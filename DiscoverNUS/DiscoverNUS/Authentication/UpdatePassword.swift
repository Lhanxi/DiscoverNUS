//
//  UpdatePassword.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 20/6/24.
//

import Foundation
import SwiftUI
    
struct UpdatePasswordView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State var currentPassword = ""
    @State var newPassword = ""
    @State var confirmPassword = ""
    
    var body: some View {
        VStack {
            SecureField("currentPassword", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Update Password") {
                Task {
                    do {
                        try viewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword)
                        print("PASSWORD UPDATED")
                    } catch {
                        print(error)
                    }
                }
            }
            Spacer()
        }
    }
}

/*
#Preview {
    UpdatePasswordView()
}
*/
