//
//  PartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 20/6/24.
//

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class PartyViewModel : ObservableObject {
    @Published var partyCode: String
    @Published var users: [UserModel] = []
    private var listener: ListenerRegistration?

    struct UserModel: Identifiable {
        var id: String
        var isLeader: Bool
    }

    init(partyCode: String) {
        self.partyCode = partyCode
        fetchUsers()
    }
    
    deinit {
        listener?.remove()
    }

    func fetchUsers() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users")
        
        listener = partyRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.users = documents.compactMap { document in
                let data = document.data()
                return UserModel(
                    id: data["userID"] as? String ?? "",
                    isLeader: data["isLeader"] as? Bool ?? false
                )
            }
            
        }
    }

    func deleteParty() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
        
        partyRef.delete { error in
            if let error = error {
                print("Error deleting party: \(error.localizedDescription)")
            } else {
                print("Party successfully deleted")
            }
        }
    }

    func leaveParty() {
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
            let db = Firestore.firestore()
            
            let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
            let usersCollectionRef = partyRef.collection("Users")
            
            usersCollectionRef.document(userID).delete { error in
                if let error = error {
                    print("Error leaving party: \(error.localizedDescription)")
                } else {
                    print("Successfully left party")
                    self.assignNewLeaderIfNeeded()
                    self.deletePartyIfEmpty()
                }
            }
        } catch {
            print("Error leaving party: \(error.localizedDescription)")
        }
    }
    
    func assignNewLeaderIfNeeded() {
        guard let newLeaderID = self.users.first?.id else {
            return
        }
        
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
        let newLeaderRef = partyRef.collection("Users").document(newLeaderID)
        
        newLeaderRef.updateData(["isLeader": true]) { error in
            if let error = error {
                print("Error assigning new leader: \(error.localizedDescription)")
            } else {
                print("New leader assigned: \(newLeaderID)")
            }
        }
    }
    
    func deletePartyIfEmpty() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users")
        
        partyRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            if documents.isEmpty {
                self.deleteParty()
            }
        }
    }

    func kickUser(userID: String) {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
        let usersCollectionRef = partyRef.collection("Users")
        
        usersCollectionRef.document(userID).delete { error in
            if let error = error {
                print("Error kicking user: \(error.localizedDescription)")
            } else {
                print("User kicked out successfully")
            }
        }
    }
}

struct PartyView: View {
    @StateObject private var viewModel: PartyViewModel
    @State private var navigateToJoinPartyView = false
    
    init(partyCode: String) {
        _viewModel = StateObject(wrappedValue: PartyViewModel(partyCode: partyCode))
    }
    
    var body: some View {
        VStack {
            Text("The Party Code is: \(viewModel.partyCode)")
                .padding()
            
            List(viewModel.users) { user in
                HStack {
                    Text(user.id)
                    Spacer()
                    if user.isLeader {
                        Text("(Leader)")
                            .foregroundColor(.blue)
                    } else {
                        Button(action: {
                            viewModel.kickUser(userID: user.id)
                        }) {
                            Text("Kick")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Button(action: {
                viewModel.leaveParty()
                navigateToJoinPartyView = true
            }) {
                Text("Leave Party")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: JoinPartyView(), isActive: $navigateToJoinPartyView) {
                EmptyView()
            }
        }
        .padding()
    }
}

#Preview {
    PartyView(partyCode: "testCode")
}


