//
//  UserStatistics.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 12/7/24.
//

import Foundation
import SwiftUI
    
struct UserStatistics: View {
    var playerInfo: Player
    @State var expToNext: Int?
    @StateObject private var viewModel: PlayerModelViewModel
    @Binding var showSignInView: Bool
    
    init(showSignInView: Binding<Bool>, playerInfo: Player) {
        self._showSignInView = showSignInView
        self.playerInfo = playerInfo
        _viewModel = StateObject(wrappedValue: PlayerModelViewModel(showSignInView: showSignInView.wrappedValue, playerInfo: playerInfo))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            UserPhotoPicker(userImage: playerInfo.image, userID: playerInfo.id!)

            Text(playerInfo.username)
                .foregroundColor(Color.black)
                .font(.title2)
                .fontWeight(.bold)
                .padding(10)

            Text(viewModel.email)
                .foregroundColor(Color.black)
                .font(.system(size: 10))
                .padding(.bottom, 30)
            
            
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 50))
                
                VStack() {
                    HStack {
                        Text("\(playerInfo.exp) Exp Points")
                            .foregroundColor(.blue)
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .frame(width: geometry.size.width, height: 30)

                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(Float(playerInfo.exp) / Float(LevelSystem.expToNext(level: playerInfo.level))), height: 30)
                        }
                    }
                    .offset(y:10)
                    HStack {
                        Text("LEVEL \(playerInfo.level)")
                            .foregroundColor(Color.blue)
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(LevelSystem.expToNext(level: playerInfo.level) - playerInfo.exp) Exp to LEVEL \(playerInfo.level + 1)")
                            .foregroundColor(.blue)
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 350)
            .frame(maxHeight: 120)
            .background(Color(UIColor.systemGray6))
            
            HStack {
                Spacer()
                Text("Multiplayer Games Played: \(playerInfo.multiplayerGamesPlayed)")
                    .foregroundColor(Color.black)
                    .font(.system(size: 10))
            }
            .padding(.trailing,10)
            
            HStack {
                Spacer()
                Text("Multiplayer Games Won: \(playerInfo.multiplayerGamesWon)")
                    .foregroundColor(Color.black)
                    .font(.system(size: 10))
            }
            .padding(.trailing,10)
        }
        .offset(y:-100)
    }
}

/*
#Preview {
    UpdatePasswordView()
}
*/
