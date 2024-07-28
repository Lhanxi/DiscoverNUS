//
//  LevelUpView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 24/7/24.
//

import SwiftUI
import ConfettiSwiftUI

struct LevelUpView: View {
    @State var playerInfo: Player
    @State private var confettiCounter = 0
    @State var navigateToHome: Bool = false
    @State private var showText = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("Map")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: -50)
                
                VStack {
                    Spacer().frame(height: 50)
                    
                    HStack {
                        // Existing text and arrow image
                        Text("Lv.\(playerInfo.level)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        ZStack {
                            // Overlay for new text
                            if showText {
                                Text("Lv.\(playerInfo.level + 1)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .transition(.opacity) 
                                    .onAppear {
                                        // Trigger confetti when the view appears
                                        confettiCounter += 1
                                    }
                                    .opacity(showText ? 1 : 0) // Control opacity based on showText
                                    .animation(.easeIn(duration: 2.0), value: showText) // Animate opacity
                            }
                        }
                    }
                    .padding()
                    
                    // Gradient rectangle
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        stops: [
                                            .init(color: Color.white, location: 0.0),
                                            .init(color: Color.white, location: 0.3),
                                            .init(color: Color(hex: "#9DB7DD"), location: 0.65),
                                            .init(color: Color(hex: "#5687CE"), location: 1.0)
                                        ]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 300, height: 450)
                            .shadow(radius: 10)
                        
                        VStack {
                            Image(.levelup)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 75)
                            
                            Image(.medal)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .foregroundColor(.yellow)
                            
                            Text("You are Awesome!")
                                .font(.headline)
                                .padding(.top, 10)
                            
                            Text("Congratulations for leveling up!")
                                .font(.system(size: 15))
                                .padding()
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(destination: RootView(), isActive: $navigateToHome) {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                    .frame(height: 55)
                                    .frame(maxWidth: 180)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .padding(.top, 20)
                        }
                        .offset(y: -20)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .confettiCannon(counter: $confettiCounter, num: 50, confettiSize: 15.0, radius: 420.0)
        }
        .navigationBarHidden(true) // Hides the navigation bar
        .onAppear {
            // Delay the display of the new text
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showText = true
                }
            }
        }
    }
}

struct LevelUpView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample player instance
        let samplePlayer = Player(id: "Sample Player",
                                  level: 8,
                                  username: "John",
                                  exp: 0,
                                  image: Image(systemName: "person.fill"),
                                  quests: [],
                                  multiplayerGamesPlayed: 0,
                                  multiplayerGamesWon: 0)
        // Use State for the binding
        return LevelUpView(playerInfo: samplePlayer)
    }
}
