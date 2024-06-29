//
//  MultiPlayerView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 17/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MultiPlayerView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Multiplayer Mode")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    NavigationLink(destination: CreatePartyView()) {
                        Text("Create Party")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: JoinPartyView()) {
                        Text("Join Party")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MultiPlayerView()
}
