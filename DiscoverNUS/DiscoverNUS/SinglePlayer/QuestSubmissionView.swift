//
//  QuestSubmission.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 18/7/24.
//

import Foundation
import SwiftUI

struct QuestSubmissionView: View {
    let quest: Quest
    @State var timeLimit: Int
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var navigateBackToHomePage = false
    @State var navigateForward = false
    
    var body: some View {
            VStack {
                HStack{
                    Button(action: {
                        self.navigateBackToHomePage = true
                    }) {
                        Text("Cancel Quest")
                            .padding(10)
                    }
                    Spacer()
                }
                Text(quest.name)
                    .padding()
                Spacer()
                Text("\(timeLimit)").onAppear() {
                    self.startTimer()
                }
                Spacer()
                Spacer()
                Image(uiImage: quest.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding()
                Spacer()
                Text(quest.description)
                    .padding()
                Spacer()
                Button(action: {
                    self.navigateForward = true
                }) {
                    Text("Submit Quest")
                }
                .padding()
            }
            
            NavigationLink(destination: RootView(), isActive: $navigateBackToHomePage) {
            }
            .hidden()
        NavigationLink(destination: CompleteQuest(quest: quest, showSignInView: $showSignInView, playerInfo: $playerInfo, timeLimit: timeLimit, questImage: Image(uiImage: quest.image)), isActive: $navigateForward){
            }
            .hidden()
        .navigationBarHidden(true)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { result in
            if self.timeLimit > 0 {
                self.timeLimit -= 1
            } else {
                self.navigateBackToHomePage = true
            }
        }
    }
}
