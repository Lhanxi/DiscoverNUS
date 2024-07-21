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
    @State private var showAlert = false
    @State private var timerMode: TimerMode = .textRevealing
    
    enum TimerMode {
        case textRevealing
        case countdown
    }
    
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
                        .offset(y: 65)
                    
                    VStack {
                        Text(visibleText)
                            .font(.system(size: 10))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .onAppear {
                                startTimer()
                            }
                        
                        if isTextFullyRevealed {
                            HStack {
                                Text("(\(timeLimit)s)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                                    .padding(.bottom, 10)
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                NavigationLink(destination: CompleteQuest(quest: quest, showSignInView: $showSignInView, playerInfo: $playerInfo, timeLimit: timeLimit, questImage: Image(uiImage: quest.image)), isActive: $navigateForward) {
                                    Text("Submit Quest >")
                                        .foregroundColor(.red)
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
                    .frame(maxWidth: 330, minHeight: 280)
                }
            }
            .navigationBarItems(leading: Button(action: {
                showAlert = true
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
                    .foregroundColor(.blue)
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Cancel Quest"),
                    message: Text("Are you sure you want to cancel the quest?"),
                    primaryButton: .destructive(Text("Yes")) {
                        navigateBackToHomePage = true
                    },
                    secondaryButton: .cancel()
                )
            }
            .background(
                NavigationLink(destination: RootView(), isActive: $navigateBackToHomePage) {
                    EmptyView()
                }
            )
        }
        .navigationBarHidden(true) // Hides the navigation bar
        .onTapGesture {
            revealFullText()
        }
    }
    
    func startTimer() {
        fullText = quest.description
        visibleText = ""
        isTextFullyRevealed = false
        
        timerMode = .textRevealing
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            switch timerMode {
            case .textRevealing:
                if visibleText.count < fullText.count {
                    let nextIndex = fullText.index(fullText.startIndex, offsetBy: visibleText.count)
                    visibleText.append(fullText[nextIndex])
                } else {
                    isTextFullyRevealed = true
                    timerMode = .countdown
                    timer?.invalidate()
                    startCountdown()
                }
            case .countdown:
                break // Do nothing in countdown mode here
            }
        }
    }
    
    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLimit > 0 {
                timeLimit -= 1
            } else {
                navigateForward = true
                timer?.invalidate()
            }
        }
    }
    
    func revealFullText() {
        visibleText = fullText
        isTextFullyRevealed = true
        timer?.invalidate()
        startCountdown()
    }
}
