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
    
    func updatePassword(currentPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Error?) -> Void) throws {
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
            HStack{
                NavigationLink(destination: RootView()){
                    Text("Back")
                        .padding(10)
                }
                Spacer()
            }
            
            VStack{
                UserPhotoPicker(userImage: image, userID: userID)
            }
            
            ZStack {
                if self.edit {
                    TextField("Username", text: $username)
                        .padding()
                        .multilineTextAlignment(.leading)
                } else {
                    Text(username)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
                
                HStack {
                    Spacer()
                    Image(systemName: "pencil")
                        .onTapGesture{
                            self.edit.toggle()
                        }
                        .padding()
                }.onChange(of: edit) { edit in
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
            }
            
            List {
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
