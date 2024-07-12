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
    @State var navigateBack = false
    @State var completedUpdatePassword = false
    
    var body: some View {
        VStack {
            Text("Current Password:")
            SecureField("Enter text here", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("New Password:")
            SecureField("Enter text here", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("Confirm Password:")
            SecureField("Enter text here", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button() {
                Task {
                    try viewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword) { error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            self.completedUpdatePassword = true
                            print("PASSWORD UPDATED")
                        }
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: 150)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }.alert(isPresented: $completedUpdatePassword) {
                Alert(
                    title: Text("Success"),
                    message: Text("Password updated!"),
                    dismissButton: .default(Text("OK")){
                        self.navigateBack = true
                    })
            }
            Spacer()
        }
        NavigationLink(destination: RootView(), isActive: $navigateBack){}
    }
}

/*
#Preview {
    UpdatePasswordView()
}
*/
