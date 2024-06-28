//
//  PlayerModel.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 8/6/24.
//

import SwiftUI

//data structure of player
struct Player: Identifiable, Codable {
    let id: String?
    var level: Int
    var imageURL: String // URL to the player's image
    var quests: [String] 
    var multiplayerGamesPlayed: Int
    var multiplayerGamesWon: Int

    // CodingKeys to map properties to Firestore document fields
    enum CodingKeys: String, CodingKey {
        case id
        case level
        case imageURL
        case quests
        case multiplayerGamesPlayed
        case multiplayerGamesWon
    }

    init(id: String? = nil, level: Int = 1, imageURL: String = "", quests: [String] = ["", "", ""], multiplayerGamesPlayed: Int = 0, multiplayerGamesWon: Int = 0) {
        self.id = id
        self.level = level
        self.imageURL = imageURL
        self.quests = quests
        self.multiplayerGamesPlayed = multiplayerGamesPlayed
        self.multiplayerGamesWon = multiplayerGamesWon
    }
    
    // Custom encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(level, forKey: .level)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(quests, forKey: .quests)
        try container.encode(multiplayerGamesPlayed, forKey: .multiplayerGamesPlayed)
        try container.encode(multiplayerGamesWon, forKey: .multiplayerGamesWon)
    }

    // Custom decoding function
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.level = try container.decode(Int.self, forKey: .level)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.quests = try container.decode([String].self, forKey: .quests)
        self.multiplayerGamesPlayed = try container.decode(Int.self, forKey: .multiplayerGamesPlayed)
        self.multiplayerGamesWon = try container.decode(Int.self, forKey: .multiplayerGamesWon)
    }
}

//UI structure of player model
struct PlayerModelView: View {
    @State private var isDropDownVisible = false
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let widthSize = min(max(geometry.size.width * 0.3, 150), 200)
            let heightSize = min(max(geometry.size.width * 0.3, 150), 200)
            let finalSize = max(widthSize, heightSize)
            VStack{
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: finalSize,
                               height: finalSize)
                    
                    //replace person.fill with what you get from firebase
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: finalSize * 0.8,
                               height: finalSize * 0.8)
                }
                .onTapGesture {
                    self.isDropDownVisible.toggle()
                }
                
                if isDropDownVisible {
                    VStack {
                        Spacer()
                        Button(action: {
                            self.isDropDownVisible.toggle()
                            //navigate to settingspage
                        }) {
                            Text("Change Profile")
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                        Button(action: {
                            self.isDropDownVisible.toggle()
                            do {
                                try viewModel.signOut()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }) {
                            Text("logout")
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    }
                    .frame(width: finalSize, height: finalSize * 0.5)
                    .background(Color.gray)
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
            }
        }
    }
}

/*
#Preview {
    PlayerModelView()
}
*/
