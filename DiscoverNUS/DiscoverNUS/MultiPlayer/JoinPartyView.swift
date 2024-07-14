//
//  JoinPartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 20/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AVFoundation

@MainActor
final class JoinPartyViewModel: ObservableObject {
    @Published var partyCode = ""
    @Published var errorMessage: String?
    
    func joinParty() async {
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
            let profile = ImageHandler()
            let player = try await AuthenticationManager.shared.getUserDocument(profile: profile, userId: userID)
            
            let db = Firestore.firestore()
            
            let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
            let partySnapshot = try await partyRef.getDocument()
            
            guard partySnapshot.exists else {
                DispatchQueue.main.async {
                    self.errorMessage = "Party does not exist"
                }
                return
            }
            
            let userRef = partyRef.collection("Users").document(userID)
            try await userRef.setData([
                "userID": player.id,
                "level": player.level,
                "username": player.username,
                "quests": player.quests,
                "multiplayerGamesPlayed": player.multiplayerGamesPlayed,
                "multiplayerGamesWon": player.multiplayerGamesWon,
                "isLeader": false,
                "isKicked": false,
                "inQuiz": false,
                "playerScore": 0
            ])
            
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error joining party: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to join the party: \(error.localizedDescription)"
            }
        }
    }
}

struct JoinPartyView: View {
    @StateObject private var viewModel = JoinPartyViewModel()
    @State private var navigateToPartyView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image(.background)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)
                
                VStack(spacing: 30) {
                    Spacer().frame(height: 50) // Shift everything upwards
                    
                    Text("Join Game")
                        .font(.title2)
                    
                    TextField("Enter Party Code", text: $viewModel.partyCode)
                         .frame(height: 55)
                         .padding(.leading, 10)
                         .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                         .frame(height: 55)
                         .frame(maxWidth: 350)
                         .overlay(
                             RoundedRectangle(cornerRadius: 30)
                                 .stroke(Color.gray, lineWidth: 1)
                         )
                         .textFieldStyle(PlainTextFieldStyle())

                         .overlay(
                             Button(action: {
                                 Task {
                                     await viewModel.joinParty()
                                     if viewModel.errorMessage == nil {
                                         navigateToPartyView = true
                                     }
                                 }
                             }) {
                                 Text("Enter Code")
                                     .font(.headline)
                                     .foregroundColor(Color.white)
                                     .frame(height: 50)
                                     .frame(maxWidth: 100)
                                     .background(
                                         LinearGradient(gradient: Gradient(colors: [Color.orange, Color(red: 1.0, green: 0.5, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                     )
                                     .cornerRadius(30)
                             }
                                 .padding(.trailing, 5),
                                 alignment: .trailing
                         )
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    ZStack {
                        QRScannerView { code in
                            viewModel.partyCode = code
                            Task {
                                await viewModel.joinParty()
                                if viewModel.errorMessage == nil {
                                    navigateToPartyView = true
                                }
                            }
                        }
                        .frame(width: 300, height: 300)
                        .cornerRadius(2)
                        .background(Color.black.opacity(0.1))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        .overlay(
                            CornerLinesOverlay()
                                .frame(width: 320, height: 320)
                        )
                    }
                    
                    NavigationLink(destination: PartyView(partyCode: viewModel.partyCode), isActive: $navigateToPartyView) {
                        EmptyView()
                    }
                    
                    Spacer()  // Add a spacer to push everything up
                }
                .padding(.top, -70)  // Adjust the padding to shift everything upwards
            }
        }
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 90, height: 7)
            .cornerRadius(20)
    }
}

struct CornerLines: View {
    var body: some View {
        VStack {
            Line()
                .rotationEffect(.degrees(90))
                .offset(x: 20, y: -14)
            Line()
                .rotationEffect(.degrees(-180))
                .offset(x: -22, y: 13)
        }
    }
}

struct CornerLinesOverlay: View {
    var body: some View {
        ZStack {
            CornerLines()
                .rotationEffect(.degrees(180))
                .offset(x: -135, y: -135)
            CornerLines()
                .rotationEffect(.degrees(-90))
                .offset(x: 135, y: -135)
            CornerLines()
                .rotationEffect(.degrees(90))
                .offset(x: -135, y: 135)
            CornerLines()
                .offset(x: 135, y: 135)
        }
    }
}

#Preview {
    JoinPartyView()
}
