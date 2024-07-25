//
//  QuestSuccessfulView.swift
//  DiscoverNUS
//  Created by Leung Han Xi on 24/7/24.
//

import SwiftUI
import ConfettiSwiftUI

struct QuestSuccessfulView: View {
    @State private var confettiCounter = 0
    @State var navigateToHome: Bool = false
    let quest: Quest
    @State var timeLimit: Int
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var levelUp: Bool
    @State private var showImage = true
    @State var expGained: Int
    @State var currentExp: Int
    
    @State private var displayedExp: Int = 0 // New state variable for animation
    @State private var isLevelingUp = false // New state variable to handle level up transition

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image(uiImage: quest.image)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.7)
                
                VStack {
                    // Conditional rendering based on showImage state
                    if showImage {
                        Image(.questcomplete)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 100)
                            .offset(y: 50)
                            .onAppear {
                                // Trigger confetti when the view appears
                                confettiCounter += 1
                                
                                // Schedule image to disappear after 5 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    withAnimation {
                                        showImage = false
                                    }
                                }
                            }
                    } else {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 50))
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(displayedExp) Exp Points")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                    .onAppear {
                                        // Animate EXP points
                                        let totalExp = currentExp + expGained
                                        let expToNextLevel = LevelSystem.expToNext(level: playerInfo.level)
                                        
                                        if totalExp >= expToNextLevel {
                                            // Level up logic
                                            isLevelingUp = true
                                            withAnimation(Animation.linear(duration: 2.0)) {
                                                displayedExp = expToNextLevel
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                playerInfo.level += 1
                                                currentExp = 0
                                                let remainingExp = totalExp - expToNextLevel
                                                let nextExpToNextLevel = LevelSystem.expToNext(level: playerInfo.level)
                                                displayedExp = 0
                                                withAnimation(Animation.linear(duration: 2.0)) {
                                                    displayedExp = remainingExp
                                                }
                                                isLevelingUp = false
                                            }
                                        } else {
                                            withAnimation(Animation.linear(duration: 2.0)) {
                                                displayedExp = totalExp
                                            }
                                        }
                                    }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .frame(width: geometry.size.width, height: 20) // Fixed height for the progress bar

                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.blue)
                                            .frame(width: geometry.size.width * CGFloat(Float(displayedExp) / Float(LevelSystem.expToNext(level: playerInfo.level))), height: 20) // Match height here
                                    }
                                }
                                .frame(height: 20) // Constrain height to match the content
                                .padding(.top, 5)
                                
                                HStack {
                                    Text("LEVEL \(playerInfo.level + 1)")
                                        .foregroundColor(Color.blue)
                                        .font(.system(size: 10))
                                        .fontWeight(.bold)
                                        .padding(.top,10)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: 350)
                        .frame(maxHeight: 100)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }

                    ZStack {
                        VStack {
                            Spacer()
                            Image(.scroll)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 300)
                                .offset(y: 30)
                        }
                        // Shadow effect
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.1)]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 60)
                            .offset(y: 160)
                        
                        VStack {
                            Image(.happylion)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 450, height: 300)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                            
                            HStack {
                                if levelUp {
                                    NavigationLink(destination: LevelUpView(playerInfo: playerInfo)) {
                                        Text("Return to Menu >")
                                            .foregroundColor(.red)
                                            .font(.system(size: 18))
                                    }
                                    .offset(x: 100, y: 90)
                                } else {
                                    NavigationLink(destination: RootView(), isActive: $navigateToHome) {
                                        Text("Return to Menu >")
                                            .foregroundColor(.red)
                                            .font(.system(size: 18))
                                    }
                                    .offset(x: 100, y: 90)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .confettiCannon(counter: $confettiCounter, num: 50, confettiSize: 15.0, radius: 420.0)
            }
        }
        .navigationBarHidden(true)
    }
}
