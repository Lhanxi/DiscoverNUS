//
//  OverallLeaderboardView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 24/7/24.
//

import Foundation
import SwiftUI


struct OverallLeaderBoardView: View {
    @Binding var showSignInView: Bool
    @State var backToHomePage = false
    @State var leaderboardArray: [LeaderBoardPlayer] = []
    @State var multiPlayerBoardArray: [LeaderBoardMultiPlayer] = []
    var playerInfo: Player
    @State var currentRank = "-"
    @State var multiPlayerRank = "-"
    @State var multiPlayerBoard = false
    
    var body: some View {
        NavigationLink(destination: HomePage(showSignInView: $showSignInView, playerInfo: playerInfo), isActive: $backToHomePage) {
        }
        .hidden()
        
        GeometryReader { geometry in
            if multiPlayerBoard == false {
                VStack {
                    HStack{
                        Button(action: {
                            self.backToHomePage = true
                        }) {
                            Text("Back to Menu")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .frame(height: 20)
                                .frame(maxWidth: 100)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                    }.frame(height: 30)
                    
                    Text("Leaderboard")
                        .font(.largeTitle)
                        .padding(.top) // Only apply padding to the top
                        .padding([.leading, .trailing]) // Apply padding to the left and right edges
                    
                    HStack{
                        Spacer()
                        Button(action: {
                        }) {
                            Text("SinglePlayer")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                                .multilineTextAlignment(.center)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                        Button(action: {
                            self.multiPlayerBoard = true
                        }) {
                            Text("Multiplayer")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                                .multilineTextAlignment(.center)
                                .background(Color.gray)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                    }
                    
                    List {
                        Section(header: HStack {
                            Text("Rank")
                                .frame(width: 60, alignment: .center)
                            Spacer()
                            Text("Username")
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                            Spacer()
                            Text("Level")
                                .frame(width: geometry.size.width * 0.15,
                                       alignment: .center)
                            Spacer()
                            Text("Total EXP")
                                .frame(width: geometry.size.width * 0.2, alignment: .center)
                        }.frame(height: 10)) {
                            ForEach(self.leaderboardArray, id: \.id) { rankedUser in
                                HStack {
                                    ZStack(alignment: .topLeading) {
                                        ZStack{
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 40, height: 40)
                                            Text("\(rankedUser.rank)")
                                                .foregroundColor(Color.white)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 10)
                                        if rankedUser.rank == 1 {
                                            Image(systemName: "crown.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Color(hex: "#FFAA00"))
                                                .rotationEffect(.degrees(-35))
                                                .offset(x: -8, y: -10)
                                        }
                                    }.frame(width: 60)
                                    Spacer()
                                    Text(rankedUser.username)
                                        .frame(width: geometry.size.width * 0.35, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                    Spacer()
                                    Text("\(rankedUser.level)")
                                        .frame(maxWidth: geometry.size.width * 0.15, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                    Spacer()
                                    Text("\(rankedUser.totalExp)")
                                        .frame(width: geometry.size.width * 0.2, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                }
                                .padding()
                                .background(rankBackgroundColor(rank: rankedUser.rank))
                                .cornerRadius(8)
                                .frame(height: 60)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                    
                    Divider()
                    HStack {
                        ZStack(alignment: .topLeading) {
                            ZStack{
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 40, height: 40)
                                Text(self.currentRank)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 40, height: 40)
                            .padding(.leading, 10)
                        }.frame(width: 60)
                        Spacer()
                        Text(playerInfo.username)
                            .frame(width: geometry.size.width * 0.35, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                        Spacer()
                        Text("\(playerInfo.level)")
                            .frame(maxWidth: geometry.size.width * 0.15, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                        Spacer()
                        Text("\(LevelSystem.totalExp(level: playerInfo.level, currentExp: playerInfo.exp))")
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .frame(height: 60)
                    .padding()
                }
                .navigationBarHidden(true)
                .onAppear(){
                    Task{
                        do {
                            try await LeaderBoardHandler.topUsersLevel() { result in
                                self.leaderboardArray = result
                            }
                            
                            self.currentRank = try await LeaderBoardHandler.getCurrentUserLevelRank(userID: playerInfo.id!)
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            } else {
                VStack {
                    HStack{
                        Button(action: {
                            self.backToHomePage = true
                        }) {
                            Text("Back to Menu")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .frame(height: 20)
                                .frame(maxWidth: 100)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                    }.frame(height: 30)
                    
                    Text("Leaderboard")
                        .font(.largeTitle)
                        .padding(.top) // Only apply padding to the top
                        .padding([.leading, .trailing]) // Apply padding to the left and right edges
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            self.multiPlayerBoard = false
                        }) {
                            Text("SinglePlayer")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                                .multilineTextAlignment(.center)
                                .background(Color.gray)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                        Button(action: {
                        }) {
                            Text("Multiplayer")
                                .font(.system(size: 20))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                                .multilineTextAlignment(.center)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                    }
                    
                    List {
                        Section(header: HStack {
                            Text("Rank")
                                .frame(width: 60, alignment: .center)
                            Spacer()
                            Text("Username")
                                .frame(width: geometry.size.width * 0.35, alignment: .center)
                            Spacer()
                            Text("Wins")
                                .frame(width: geometry.size.width * 0.15,
                                       alignment: .center)
                            Spacer()
                            Text("Win Rate")
                                .frame(width: geometry.size.width * 0.2, alignment: .center)
                        }.frame(height: 10)) {
                            ForEach(self.multiPlayerBoardArray, id: \.id) { rankedUser in
                                HStack {
                                    ZStack(alignment: .topLeading) {
                                        ZStack{
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 40, height: 40)
                                            Text("\(rankedUser.rank)")
                                                .foregroundColor(Color.white)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 10)
                                        if rankedUser.rank == 1 {
                                            Image(systemName: "crown.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Color(hex: "#FFAA00"))
                                                .rotationEffect(.degrees(-35))
                                                .offset(x: -8, y: -10)
                                        }
                                    }.frame(width: 60)
                                    Spacer()
                                    Text(rankedUser.username)
                                        .frame(width: geometry.size.width * 0.35, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                    Spacer()
                                    Text("\(rankedUser.gamesWon)")
                                        .frame(maxWidth: geometry.size.width * 0.15, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                    Spacer()
                                    Text("\(rankedUser.winRate)")
                                        .frame(width: geometry.size.width * 0.2, alignment: .center)
                                        .font(.system(size: min(geometry.size.width * 0.03, 18)))
                                }
                                .padding()
                                .background(rankBackgroundColor(rank: rankedUser.rank))
                                .cornerRadius(8)
                                .frame(height: 60)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                    
                    Divider()
                    HStack {
                        ZStack(alignment: .topLeading) {
                            ZStack{
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 40, height: 40)
                                Text(self.multiPlayerRank)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 40, height: 40)
                            .padding(.leading, 10)
                        }.frame(width: 60)
                        Spacer()
                        Text(playerInfo.username)
                            .frame(width: geometry.size.width * 0.35, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                        Spacer()
                        Text("\(playerInfo.multiplayerGamesWon)")
                            .frame(maxWidth: geometry.size.width * 0.15, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                        Spacer()
                        Text(WinRateHandler.winRate(gamesWon: playerInfo.multiplayerGamesWon, gamesPlayed: playerInfo.multiplayerGamesPlayed))
                            .frame(width: geometry.size.width * 0.2, alignment: .center)
                            .font(.system(size: min(geometry.size.width * 0.03, 18)))
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .frame(height: 60)
                    .padding()
                }
                .navigationBarHidden(true)
                .onAppear(){
                    Task{
                        do {
                            try await LeaderBoardHandler.topUsersMultiplayer() { result in
                                self.multiPlayerBoardArray = result
                            }
                            
                            self.multiPlayerRank = try await LeaderBoardHandler.getMultiplayerUserLevelRank(userID: playerInfo.id!)
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    private func rankBackgroundColor(rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(hex: "#FDD700")
        case 2:
            return Color(hex: "#C0C0C0")
        case 3:
            return Color(hex: "#CD7F32")
        default:
            return Color(hex: "#EDEDED")
        }
    }
}
