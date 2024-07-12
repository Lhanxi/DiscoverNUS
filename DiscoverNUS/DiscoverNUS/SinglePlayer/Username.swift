//
//  Username.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 11/7/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
    
class UsernameHandler {
    static func inputUsername(username: String, userID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.updateData(["username": username]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

struct CreateUsername: View {
    @Binding var showSignInView: Bool
    @State var username = ""
    @State var playerInfo: Player
    @State var createdUsername = false
    
    var body: some View {
        VStack {
            Text("Select Username")
                .padding()
            TextField("Enter text here", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button() {
                Task {
                    if username != "" {
                        UsernameHandler.inputUsername(username: username, userID: playerInfo.id!) { error in
                            if let error = error {
                                print(error)
                            } else {
                                print("successfully created username")
                                self.createdUsername = true
                            }
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
            }
            NavigationLink(destination: RootView(), isActive: $createdUsername){
            }.navigationBarHidden(true)
            Spacer()
        }
    }
}
