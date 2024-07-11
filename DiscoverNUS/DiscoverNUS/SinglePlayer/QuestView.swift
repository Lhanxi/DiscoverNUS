//
//  QuestView.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import SwiftUI

//UI structure for quests
struct QuestView: View {
    let quest: Quest
    @Binding var showSignInView: Bool
    var playerInfo: Player
    
    var body: some View {
        VStack {
            Text(quest.name)
                .padding()
            
            Image(uiImage: quest.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
            
            Text(quest.description)
                .padding()
            
            //placeholder for timer for now, replace later
            NavigationLink(destination: {
                StartQuest(quest: quest, timer: 60, showSignInView: $showSignInView, playerInfo: playerInfo)
            }) {
                Text("Start Quest")
            }
            .padding()
        }
        .frame(width: 200, height: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius:5)
    }
}

