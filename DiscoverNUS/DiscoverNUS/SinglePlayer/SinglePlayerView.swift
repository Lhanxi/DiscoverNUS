//
//  SinglePlayerView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 16/7/24.
//

import SwiftUI

struct SinglePlayerView: View {
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var selectQuest = false
    @State var selectedQuest: Quest?
    @ObservedObject var userQuests = QuestArrayManager()
    
    var body: some View {
        ZStack {
            MapsView(selectQuest: $selectQuest, selectedQuest: $selectedQuest, questManager: userQuests)
                .edgesIgnoringSafeArea(.all)
            
            if selectQuest {
                // Transparent overlay to detect taps and hide the menu
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            selectQuest = false
                        }
                    }

                if let quest = selectedQuest {
                    QuestView(quest: quest, showSignInView: $showSignInView, playerInfo: playerInfo, isPresented: $selectQuest)
                        .transition(.slideUp)
                        .zIndex(1) // Ensures the QuestView is above the overlay
                        .onTapGesture {
                            // Prevents the QuestView itself from triggering the overlay tap gesture
                            // Do nothing to handle the tap on the QuestView itself
                        }
                }
            }
        }.onAppear() {
            if self.playerInfo.quests.count < 3 {
                QuestManager.newQuest(count: self.playerInfo.quests.count, playerInfo: playerInfo) { result in
                    self.playerInfo = result
                }
            }
            SinglePlayerView.getUserQuests(questIDList: playerInfo.quests) { result in
                self.userQuests.add(questList: result)
            }
        }
    }
    
    static func getUserQuests(questIDList: [String], completion: @escaping ([Quest]) -> Void) {
        var quests: [Quest] = []
        let group = DispatchGroup()
        
        for questID in questIDList {
            group.enter()
            QuestManager.getQuest(imageHandler: ImageHandler(), questId: questID) { result in
                quests.append(result)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("All quests fetched")
            completion(quests)
        }
    }
}
