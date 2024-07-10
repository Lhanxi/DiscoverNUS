//
//  CreatePartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 17/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor
final class CreatePartyViewModel: ObservableObject {
    @Published var partyCode: String = ""
    
    func generatePartyCode() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map{ _ in letters.randomElement()! })
    }
    
    func createParty() async {
        let partyID = generatePartyCode()
        self.partyCode = partyID
        
        print("Generated Party ID: \(partyID)")
        
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
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
            try await userRef.setData(["userID": userID, "isLeader": true])
            
        } catch {
            print("Error creating party: \(error.localizedDescription)")
        }
    }
}

struct CreatePartyView: View {
    @StateObject private var viewModel = CreatePartyViewModel()
    @State private var navigateToPartyView = false
    
    var body: some View {
        NavigationView {
            ZStack{
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.8), Color(red: 1.0, green: 0.7, blue: 0.6)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    Text("Party Code: \(viewModel.partyCode)")
                        .padding()
                        .font(.headline)

                    Button(action: {
                        Task {
                            await viewModel.createParty()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                                                navigateToPartyView = true
                                            }
                        }
                    })
                    {
                        Text("Create Party")
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
                    
                    NavigationLink(destination: PartyView(partyCode: viewModel.partyCode), isActive: $navigateToPartyView) {
                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    CreatePartyView()
}

