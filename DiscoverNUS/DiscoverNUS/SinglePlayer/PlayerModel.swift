//
//  PlayerModel.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 8/6/24.
//

import SwiftUI

//data structure of player
struct Player {
    let id: String
    var level: Int
    var image: UIImage
    var quests: (String, String, String)
    var multiplayerGamesPlayed: Int
    var multiplayerGamesWon: Int
}

//UI structure of player model
struct PlayerModelView: View {
    @State private var isDropDownVisible = false
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
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
                        Spacer()
                        Button(action: {
                            self.isDropDownVisible.toggle()
                            //navigate to settingspage
                        }) {
                            Text("Change Profile")
                                .foregroundColor(Color.white)
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
