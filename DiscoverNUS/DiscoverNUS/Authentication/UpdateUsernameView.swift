//
//  UpdateUsernameView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 25/7/24.
//

import Foundation
import SwiftUI
    
struct UpdateUsernameView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State var newUsername = ""
    @State var navigateBack = false
    @State var completedUpdateUsername = false
    
    @Binding var showSignInView: Bool
    @State var image: Image
    @State var username: String
    var userID: String
    @State var edit: Bool = false
    
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
            
            TextField("New Username:", text: $newUsername)
                .padding()
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Color.black)
                .frame(maxWidth: 330)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                .padding(.bottom, 20)

            
            Button() {
                Task {
                    UsernameHandler.inputUsername(username: newUsername, userID: userID) { error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            self.completedUpdateUsername = true
                            print("USERNAME UPDATED")
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
            }.alert(isPresented: $completedUpdateUsername) {
                Alert(
                    title: Text("Success"),
                    message: Text("Username updated!"),
                    dismissButton: .default(Text("OK")){
                        self.navigateBack = true
                    })
            }
            Spacer()
        }
        NavigationLink(destination: RootView(), isActive: $navigateBack){}
    }
}
