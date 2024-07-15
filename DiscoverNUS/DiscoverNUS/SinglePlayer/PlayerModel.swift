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

//UI structure of player model
struct PlayerModelView: View {
    @State private var isDropDownVisible = false
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var playerInfo: Player
    
    var body: some View {
        GeometryReader { geometry in
            let widthSize = min(max(geometry.size.width * 0.3, 150), 200)
            let heightSize = min(max(geometry.size.width * 0.3, 150), 200)
            let finalSize = max(widthSize, heightSize)
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: finalSize,
                               height: finalSize)
                    
                    playerInfo.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: finalSize * 0.8,
                               height: finalSize * 0.8)
                }
                
                VStack {
                    Divider()
                    Spacer()
                    HStack{
                        Text("Username: ")
                            .foregroundColor(Color.white)
                            .font(.system(size: 15))
                            .padding(.leading)
                        Spacer()
                    }
                    HStack{
                        Text(playerInfo.username)
                            .foregroundColor(Color.white)
                            .font(.system(size: 15))
                            .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Text("Level: \(playerInfo.level)")
                            .foregroundColor(Color.white)
                            .font(.system(size: 15))
                            .padding(.leading)
                        Spacer()
                        if isDropDownVisible {
                            Image(systemName: "chevron.up")
                                .onTapGesture {
                                    self.isDropDownVisible.toggle()
                            }
                                .padding(.trailing)
                        } else {
                            Image(systemName: "chevron.down")
                                .onTapGesture {
                                    self.isDropDownVisible.toggle()
                            }
                                .padding(.trailing)
                        }
                    }
                    Spacer()
                }.frame(width: finalSize,
                        height: finalSize * 0.5)
                .background(Color.gray)
                
                if isDropDownVisible {
                    VStack(spacing: 0) {
                        NavigationLink(destination: UserStatistics(playerInfo: playerInfo)) {
                            Text("User Statistics")
                                .foregroundColor(Color.white)
                        }.onTapGesture {
                            self.isDropDownVisible.toggle()
                        }.frame(width: finalSize, height: finalSize * 0.25)
                            .background(Color.gray)
                        
                        NavigationLink(destination: SettingsView(showSignInView: $showSignInView, image: playerInfo.image, username: playerInfo.username, userID: playerInfo.id!)) {
                            Text("Update Profile")
                                .foregroundColor(Color.white)
                        }.onTapGesture {
                            self.isDropDownVisible.toggle()
                        }.frame(width: finalSize, height: finalSize * 0.25)
                            .background(Color.gray)
                        
                        Button(action: {
                            self.isDropDownVisible.toggle()
                            do {
                                try viewModel.signOut()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }) {
                            Text("logout")
                                .foregroundColor(Color.white)
                        }.frame(width: finalSize, height: finalSize * 0.25)
                            .background(Color.gray)
                    }.frame(width: finalSize)
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
            }
        }
    }
}

/*
#Preview {
    PlayerModelView()
}
*/
