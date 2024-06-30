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
            VStack{
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: finalSize,
                               height: finalSize)
                    
                    //replace person.fill with what you get from firebase
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: finalSize * 0.8,
                               height: finalSize * 0.8)
                }
                .onTapGesture {
                    self.isDropDownVisible.toggle()
                }
                
                if isDropDownVisible {
                    VStack {
                        if viewModel.authProviders.contains(.email) {
                            Spacer()
                            
                            NavigationLink(destination: SettingsView(showSignInView: $showSignInView)) {
                                Text("Update Profile")
                                    .foregroundColor(Color.white)
                            }.onTapGesture {
                                self.isDropDownVisible.toggle()
                            }
                        }
                        
                        Spacer()
                        
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
                        }
                        
                        Spacer()
                    }
                    .frame(width: finalSize, height: finalSize * 0.5)
                    .background(Color.gray)
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
