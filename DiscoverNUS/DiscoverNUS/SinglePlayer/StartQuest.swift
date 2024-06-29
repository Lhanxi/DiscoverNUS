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
    @State var timer: Int
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var navigateBackToHomePage = false
    @State var navigateForward = false
    
    var body: some View {
        VStack {
            Text(quest.title)
                .padding()
            Spacer()
            Text("\(timer)").onAppear() {
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
        
        NavigationLink(destination: HomePage(showSignInView: $showSignInView, playerInfo: self.playerInfo), isActive: $navigateBackToHomePage) {
        }
        .hidden()
        
        NavigationLink(destination: CompleteQuest(quest: quest, showSignInView: $showSignInView, playerInfo: $playerInfo), isActive: $navigateForward) {
        }
        .hidden()
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { result in
            if self.timer > 0 {
                self.timer -= 1
            } else {
                self.navigateBackToHomePage = true
            }
        }
    }
}
