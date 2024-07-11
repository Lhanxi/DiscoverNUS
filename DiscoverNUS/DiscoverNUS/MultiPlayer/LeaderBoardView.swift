//
//  LeaderBoardView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 12/7/24.
//

import SwiftUI

struct LeaderBoardView: View {
    let scores: [String: Int]
    
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(scores.sorted(by: { $0.value > $1.value }), id: \.key) { player, score in
                    HStack {
                        Text(player)
                        Spacer()
                        Text("\(score) correct answers")
                    }
                }
            }
            .padding()
        }
    }
}
#Preview {
    LeaderBoardView(scores: ["Player 1":0])
}
