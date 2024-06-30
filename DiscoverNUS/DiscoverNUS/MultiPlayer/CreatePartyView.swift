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
            VStack {
                Text("Party Code: \(viewModel.partyCode)")
                    .padding()
                
                Button(action: {
                    Task {
                        await viewModel.createParty()
                        navigateToPartyView = true
                    }
                }) 
                {
                    Text("Create Party")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: PartyView(partyCode: viewModel.partyCode), isActive: $navigateToPartyView) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    CreatePartyView()
}

