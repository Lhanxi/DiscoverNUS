//
//  QuestFailureView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 24/7/24.
//

import SwiftUI

struct QuestFailureView: View {
    @State var navigateToHome: Bool = false
    @State private var showImage = false
    let quest: Quest
    @State var timeLimit: Int
    @Binding var showSignInView: Bool
    @State var playerInfo: Player

    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: quest.image)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.7)
                
                VStack {
                    ZStack {
                        Image(.questfail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 100)
                            .offset(y: 70)
                            .padding(.leading,10)
                        
                        Image(.failure)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 100)
                            .padding(.trailing, 150)
                            .padding(.top, 30)
                            .scaleEffect(showImage ? 1 : 0.5) // Start with small scale
                            .opacity(showImage ? 1 : 0) // Start with opacity 0
                            .rotationEffect(.degrees(showImage ? 0 : -30)) // Start with slight rotation
                            .animation(
                                Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
                                    .delay(0.2)
                            )
                            .onAppear {
                                showImage = true
                            }
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
                            Image(.confusedlion)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 450, height: 300)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                            
                            HStack {
                                Image(.fgrade)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .offset(x:-50)

                                NavigationLink(destination: RootView(), isActive: $navigateToHome) {
                                    Text("Return to Menu >")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                        .offset(x:40)
                                }
                            }
                        }
                        .offset(y:50)
                        .padding(.top,10)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
