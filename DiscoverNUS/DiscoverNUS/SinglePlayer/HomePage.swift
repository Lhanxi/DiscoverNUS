//
//  HomePage.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//
import SwiftUI

struct HomePage: View {
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Welcome to NUS!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        
                        NavigationLink(destination: PlayView(showSignInView: $showSignInView, playerInfo: playerInfo)) {
                            Text("Start Game")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        }
                        
                        NavigationLink(destination: PlayerModelView(showSignInView: $showSignInView, playerInfo: playerInfo)) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        }
                        
                        Button(action: {
                            // No action for now
                        }) {
                            Text("Leaderboard")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        }
                    }
                    .offset(y:-70)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct HomePage_Previews: PreviewProvider {
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
        
        return HomePage(showSignInView: $showSignInView, playerInfo: samplePlayer)
    }
}
