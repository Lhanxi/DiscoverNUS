//
//  CreatePartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 17/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import QRCode

@MainActor
final class CreatePartyViewModel: ObservableObject {
    @Published var partyCode: String = ""
    @Published var qrCodeImage: UIImage?
    
    func generatePartyCode() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    func createParty() async {
        let partyID = generatePartyCode()
        self.partyCode = partyID
        
        print("Generated Party ID: \(partyID)")
        
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
            // Fetch player data using the getUserDocument function
            let profile = ImageHandler()
            let player = try await AuthenticationManager.shared.getUserDocument(profile: profile, userId: userID)
            
            let db = Firestore.firestore()
            
            // Create the Teams collection only if it doesn't exist
            let teamsRef = db.collection("Teams").document("DefaultTeam")
            let teamSnapshot = try await teamsRef.getDocument()
            
            if !teamSnapshot.exists {
                try await teamsRef.setData(["initialized": true])
            }
            
            let partyRef = teamsRef.collection("Parties").document(partyID)
            try await partyRef.setData(["partyID": partyID, "createdBy": userID])
            
            let userRef = partyRef.collection("Users").document(userID)
            try await userRef.setData([
                "userID": player.id,
                "level": player.level,
                "username": player.username,
                "quests": player.quests,
                "multiplayerGamesPlayed": player.multiplayerGamesPlayed,
                "multiplayerGamesWon": player.multiplayerGamesWon,
                "isLeader": true,
                "isKicked": false,
                "inQuiz": false,
                "playerScore": 0
            ])
            
            generateQRCode(from: partyID)
        } catch {
            print("Error creating party: \(error.localizedDescription)")
        }
    }
    
    func generateQRCode(from string: String) {
        do {
            let doc = try QRCode.Document(utf8String: string)
            let cgImage = try doc.cgImage(dimension: 400)
            qrCodeImage = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating QR code: \(error.localizedDescription)")
        }
    }
}

struct CreatePartyView: View {
    @ObservedObject var viewModel: CreatePartyViewModel
    @State private var navigateToPartyView = false
    @State var showSignInView: Bool
    @State var playerInfo: Player
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("Map")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(width: 350, height: 450)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                    .padding(.bottom, 30) // Move upwards by adjusting padding
                
                VStack {
                    Text("Party Code: \(viewModel.partyCode)")
                        .padding()
                        .font(.headline)
                    
                    if let qrCodeImage = viewModel.qrCodeImage {
                        Image(uiImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                    }

                    Button(action: {
                        navigateToPartyView = true
                    }) {
                        Text("Join Party")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .frame(height: 55)
                            .frame(maxWidth: 200)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.orange, Color(red: 1.0, green: 0.5, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                    NavigationLink(destination: PartyView(partyCode: viewModel.partyCode, showSignInView: showSignInView, playerInfo: playerInfo), isActive: $navigateToPartyView) {
                        EmptyView()
                    }
                }
            }
            .padding(.top, -50) // Adjust this value to move upwards
        }
    }
}

