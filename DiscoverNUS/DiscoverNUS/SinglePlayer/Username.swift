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
        VStack(spacing: 20) {
            Text("Select Username")
                .padding()
            
            HStack {
                Text("Set up a username")
                    .padding(.leading, 20)
                    .font(.title)
                    .foregroundColor(Color.blue)
                    .fontWeight(.bold)
                
                Image(systemName: "sparkles")
                    .foregroundColor(Color.yellow)
                
                Spacer()
            }
            
            HStack {
                Text("You can always change your @username later.")
                    .padding(.leading, 20)
                
                Spacer()
            }

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .cornerRadius(10)
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            
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
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .frame(height: 55)
                        .frame(maxWidth: 200)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#5687CE"), Color(hex: "#5687CE").opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.trailing, 10)
                }
            }
            NavigationLink(destination: RootView(), isActive: $createdUsername){
            }.navigationBarHidden(true)
            Spacer()
        }
    }
}


struct CreateUsername_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample player instance
        let samplePlayer = Player(id: "Sample Player",
                                  level: 0,
                                  username: "John",
                                  exp : 0,
                                  image: Image(systemName: "person.fill"),
                                  quests: [],
                                  multiplayerGamesPlayed: 0,
                                  multiplayerGamesWon: 0)
        // Use State for the binding
        @State var showSignInView = true
        
        return CreateUsername(showSignInView: $showSignInView, playerInfo: samplePlayer)
    }
}
