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
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                HStack{
                    NavigationLink(destination: RootView()){
                        Text("Back")
                            .padding(10)
                    }
                    Spacer()
                }
                
               Text("Level: \(playerInfo.level)")
               
               Text("Level Progress Bar")
               ZStack{
                   RoundedRectangle(cornerRadius: 15)
                       .stroke(Color.black, lineWidth: 5)
                       .background(Color.white)
                       .frame(width: geometry.size.width * 0.8, height: 30)
                   
                   HStack{
                       RoundedRectangle(cornerRadius: 15)
                           .fill(Color.orange)
                           .frame(width: geometry.size.width * 0.8 * CGFloat(Float(playerInfo.exp) / Float(LevelSystem.expToNext(level: playerInfo.level))), height: 30)
                       Spacer()
                   }.frame(width: geometry.size.width * 0.8, height: 30)
                       .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black, lineWidth: 5)
                        )
                   
                   
                   Text("\(playerInfo.exp) / \(LevelSystem.expToNext(level: playerInfo.level))")
                       .foregroundColor(Color.black)
               }
               .frame(width: geometry.size.width * 0.8, height: 30)
                
                Text("Multiplayer Games Played: \(playerInfo.multiplayerGamesPlayed)")
                
                Text("Multiplayer Games Won: \(playerInfo.multiplayerGamesWon)")
           }
        }
        .navigationBarHidden(true)
    }
}

/*
#Preview {
    UpdatePasswordView()
}
*/
