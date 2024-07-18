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
    
    @Binding var showSignInView: Bool
    @State var image: Image
    @State var username: String
    var userID: String
    @State var edit: Bool = false
    
    @State private var isCurrentPasswordSecure = true
    @State private var isNewPasswordSecure = true
    @State private var isConfirmPasswordSecure = true
    
    var body: some View {
        VStack {
            UserPhotoPicker(userImage: image, userID: userID)
            
            Text(username)
                .foregroundColor(Color.black)
                .font(.title2)
                .fontWeight(.bold)
                .padding(10)
            
            Text(viewModel.email)
                .foregroundColor(Color.black)
                .font(.system(size: 15))
                .padding(.bottom,30)
            
            VStack(spacing: 30) {
                HStack {
                    if self.edit {
                        TextField("Username", text: $username)
                            .padding()
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(username)
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "pencil.line")
                        .padding(.trailing,15)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.edit.toggle()
                        }
                }
                .background(Color(UIColor.systemGray6))
                .frame(maxWidth: 330)
                .cornerRadius(20)
                .onChange(of: edit) { edit in
                    if username != "" && edit == false {
                        UsernameHandler.inputUsername(username: username, userID: userID) { error in
                            if let error = error {
                                print(error)
                            } else {
                                print("successfully created username")
                            }
                        }
                    }
                }
                
                HStack {
                    if isCurrentPasswordSecure {
                        SecureField("Current Password:", text: $currentPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    } else {
                        TextField("Current Password:", text: $currentPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    }
                    Spacer()
                    Button(action: {
                        isCurrentPasswordSecure.toggle()
                    }) {
                        Image(systemName: isCurrentPasswordSecure ? "eye" : "eye.slash")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: 330)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                
                HStack {
                    if isNewPasswordSecure {
                        SecureField("New Password:", text: $newPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    } else {
                        TextField("New Password:", text: $newPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    }
                    Spacer()
                    Button(action: {
                        isNewPasswordSecure.toggle()
                    }) {
                        Image(systemName: isNewPasswordSecure ? "eye" : "eye.slash")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: 330)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                
                HStack{
                    if isConfirmPasswordSecure {
                        SecureField("Confirm Password:", text: $confirmPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    } else {
                        TextField("Confirm Password:", text: $confirmPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(Color.black)
                            .cornerRadius(20)
                    }
                    Spacer()
                    Button(action: {
                        isConfirmPasswordSecure.toggle()
                    }) {
                        Image(systemName: isConfirmPasswordSecure ? "eye" : "eye.slash")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: 330)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            }
            .padding(.bottom, 20)
            
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
                        .foregroundColor(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: 150)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.trailing, 10)
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
