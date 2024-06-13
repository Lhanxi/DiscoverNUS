//
//  QuestView.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import SwiftUI

//UI structure for quests
struct QuestView: View {
    let title: String
    let imageName: String
    let text: String
    
    var body: some View {
        VStack {
            Text(title)
                .padding()
            
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
            
            Text(text)
                .padding()
            
            Button(action: {
                //placeholder for submit quest and starting timer and displaying timer
                print("button is pressed")
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

#Preview {
    QuestView(title: "hi", imageName:"hi", text:"hi")
}
