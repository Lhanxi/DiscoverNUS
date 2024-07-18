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
    @Published var email: String = ""
    @Published var authProviders: [AuthProviderOption] = []
    
    init() {
        self.getEmail()
    }
    
    func getEmail() {
        if let userEmail = try? AuthenticationManager.shared.getAuthenticatedUser().email {
            self.email = userEmail
        } else {

            self.email = ""
        }
    }
    
    func loadAuthProviders() {
        if let providers =  try? AuthenticationManager.shared.getProvider() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func updatePassword(currentPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Error?) -> Void) throws {
        let authUser = Auth.auth().currentUser!
        
        guard let userEmail = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: currentPassword)
        
        authUser.reauthenticate(with: credential) { authResult, error in
            if let _ = error {
                //throw error for user authentication error
                print("unable to authenticate user")
            } else if confirmPassword != newPassword {
                //throw some error
                print("password not the same")
            } else {
                authUser.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: newPassword)
                        authUser.reauthenticate(with: credential) {
                            authResult, error in
                            if let error = error {
                                completion(error)
                            } else {
                                print("success")
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
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
                
                if viewModel.authProviders.contains(.email) {
                    NavigationLink(destination: UpdatePasswordView(showSignInView: $showSignInView, image: image, username: username, userID: userID)) {
                        HStack {
                            Text("Update Password")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "pencil.line")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .frame(maxWidth: 330)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                    }
                }
                
            }
        }
        .padding()
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .offset(y:-140)
    }
}
