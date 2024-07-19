//
//  PlayerModel.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 8/6/24.
//

import SwiftUI

//data structure of player
struct Player: Equatable {
    let id: String?
    var level: Int
    var username: String
    var exp: Int
    var image: Image // URL to the player's image
    var quests: [String]
    var multiplayerGamesPlayed: Int
    var multiplayerGamesWon: Int
}

extension Player {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.level == rhs.level && lhs.image == rhs.image && lhs.quests == rhs.quests
    }
}

final class PlayerModelViewModel: ObservableObject {
    @Published var playerInfo: Player?
    @Published var showSignInView: Bool
    @Published var authProviders: [AuthProviderOption] = []
    @Published var email: String = ""
    
    init(showSignInView: Bool, playerInfo: Player?) {
        self.showSignInView = showSignInView
        self.playerInfo = playerInfo
        self.getEmail()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func loadAuthProviders() {
        if let providers =  try? AuthenticationManager.shared.getProvider() {
            authProviders = providers
        }
    }
    
    func getEmail() {
        if let userEmail = try? AuthenticationManager.shared.getAuthenticatedUser().email {
            self.email = userEmail
        } else {

            self.email = ""
        }
    }
}

// UI structure of player model
struct PlayerModelView: View {
    @StateObject private var viewModel: PlayerModelViewModel
    @Binding var showSignInView: Bool
    var playerInfo: Player
    @State private var showLogoutAlert = false

    init(showSignInView: Binding<Bool>, playerInfo: Player) {
        self._showSignInView = showSignInView
        self.playerInfo = playerInfo
        _viewModel = StateObject(wrappedValue: PlayerModelViewModel(showSignInView: showSignInView.wrappedValue, playerInfo: playerInfo))
    }

    var body: some View {
        VStack {
            UserPhotoPicker(userImage: playerInfo.image, userID: playerInfo.id!)

            Text(playerInfo.username)
                .foregroundColor(Color.black)
                .font(.title2)
                .fontWeight(.bold)
                .padding(10)
            
            Text(viewModel.email)
                .foregroundColor(Color.black)
                .font(.system(size: 15))
                .padding(.bottom,30)

            VStack(spacing: 30) {
                NavigationLink(destination: SettingsView(showSignInView: $showSignInView, image: playerInfo.image, username: playerInfo.username, userID: playerInfo.id!)) {
                    HStack {
                        Image(systemName: "pencil.line")
                            .foregroundColor(.blue)
                            .font(Font.system(size: 15, weight: .bold))
                        Text("Edit Profile")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: 330)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                }

                NavigationLink(destination: UserStatistics(showSignInView: $showSignInView, playerInfo: playerInfo)) {
                    HStack {
                        Image(systemName: "scope")
                            .foregroundColor(.blue)
                        Text("User Statistics")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: 330)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                }

                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.backward")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: 330)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Confirm Logout"),
                        message: Text("Are you sure you want to log out?"),
                        primaryButton: .destructive(Text("Log Out")) {
                            do {
                                try viewModel.signOut()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .offset(y:-100)
    }
}

struct PlayerModelView_Previews: PreviewProvider {
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
        
        return PlayerModelView(showSignInView: $showSignInView, playerInfo: samplePlayer)
    }
}
