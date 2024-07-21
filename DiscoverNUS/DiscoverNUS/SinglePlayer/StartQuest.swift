//
//  StartQuest.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 28/6/24.
//

import Foundation
import SwiftUI

struct StartQuest: View {
    let quest: Quest
    @State var timeLimit: Int
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var navigateBackToHomePage = false
    @State var navigateForward = false
    @State private var isBlinking = false
    
    @State private var visibleText = ""
    @State private var fullText: String = ""
    @State private var timer: Timer? = nil
    @State private var isTextFullyRevealed = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: quest.image)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        revealFullText()
                    }
                
                VStack {
                    Spacer()
                    Image(.scroll)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 350, height: 300)
                        .offset(y: 25)
                }
                
                VStack {
                    Spacer()
                    Image(.mascot)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .padding(.trailing, 190)
                        .offset(y: 75)
                    
                    Text(visibleText)
                        .font(.system(size: 10))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 330, minHeight: 280)
                        .onAppear {
                            startRevealingText()
                        }
                    
                    if isTextFullyRevealed {
                        NavigationLink(destination: {
                            QuestSubmissionView(quest: quest, timeLimit: quest.timelimit, showSignInView: $showSignInView, playerInfo: playerInfo)
                        }) {
                            Text("Tap to Continue")
                                .foregroundColor(.black)
                                .font(.system(size: 10))
                                .opacity(isBlinking ? 0 : 1)
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                        isBlinking.toggle()
                                    }
                                }
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            navigateForward = true
                        })
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                navigateBackToHomePage = true
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
                    .foregroundColor(.blue)
            })
            .background(
                NavigationLink(destination: RootView(), isActive: $navigateBackToHomePage) {
                    EmptyView()
                }
            )
        }
        .navigationBarHidden(true) // Hides the navigation bar
        .onTapGesture {
            if isTextFullyRevealed {
                navigateForward = true
            } else {
                revealFullText()
            }
        }
        .background(
            NavigationLink(destination: QuestSubmissionView(quest: quest, timeLimit: quest.timelimit, showSignInView: $showSignInView, playerInfo: playerInfo), isActive: $navigateForward) {
                EmptyView()
            }
        )
    }
    
    func startRevealingText() {
        fullText = quest.description
        visibleText = ""
        isTextFullyRevealed = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if visibleText.count < fullText.count {
                let nextIndex = fullText.index(fullText.startIndex, offsetBy: visibleText.count)
                visibleText.append(fullText[nextIndex])
            } else {
                timer?.invalidate()
                isTextFullyRevealed = true
            }
        }
    }
    
    func revealFullText() {
        timer?.invalidate()
        visibleText = fullText
        isTextFullyRevealed = true
    }
}
