//
//  LeaderBoardView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 12/7/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class LeaderBoardViewModel:ObservableObject {
    @Published var users: [UserRef] = []
    @Published var navigateLeaveQuiz: Bool = false
    @Published var currentUser: UserRef?
    
    @Published var partyCode: String
    
    struct UserRef: Identifiable {
        var id: String
        var level: Int
        var username: String
        var quests: [String]
        var multiplayerGamesPlayed: Int
        var multiplayerGamesWon: Int
        var isLeader: Bool
        var isKicked: Bool
        var inQuiz: Bool
        var playerScore: Int
    }
    
    private var listener: ListenerRegistration?
    
    init(partyCode: String) {
        self.partyCode = partyCode
        fetchCurrentUser()
        fetchUsers()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }

        let userID = user.uid
        let db = Firestore.firestore()
        let userRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users").document(userID)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("Current user document does not exist.")
                return
            }

            self.currentUser = UserRef(
                id: userID,
                level: data["level"] as? Int ?? 0,
                username: data["username"] as? String ?? "",
                quests: data["quests"] as? [String] ?? [],
                multiplayerGamesPlayed: data["multiplayerGamesPlayed"] as? Int ?? 0,
                multiplayerGamesWon: data["multiplayerGamesWon"] as? Int ?? 0,
                isLeader: data["isLeader"] as? Bool ?? false,
                isKicked: data["isKicked"] as? Bool ?? false,
                inQuiz: data["inQuiz"] as? Bool ?? false,
                playerScore: data["playerScore"] as? Int ?? 0
            )
        }
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
                return UserRef(
                    id: data["userID"] as? String ?? "",
                    level: data["level"] as? Int ?? 0,
                    username: data["username"] as? String ?? "",
                    quests: data["quests"] as? [String] ?? [],
                    multiplayerGamesPlayed: data["multiplayerGamesPlayed"] as? Int ?? 0,
                    multiplayerGamesWon: data["multiplayerGamesWon"] as? Int ?? 0,
                    isLeader: data["isLeader"] as? Bool ?? false,
                    isKicked: data["isKicked"] as? Bool ?? false,
                    inQuiz: data["inQuiz"] as? Bool ?? false,
                    playerScore: data["playerScore"] as? Int ?? 0
                )
            }
            self.listenForQuizStatus()
        }
    }
    
    func listenForQuizStatus() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users").document(userID)

        userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error listening for quiz status: \(error.localizedDescription)")
                return
            }

            guard let document = documentSnapshot, let data = document.data() else {
                print("No document found for current user")
                return
            }

            if let inQuiz = data["inQuiz"] as? Bool, !inQuiz {
                self.navigateLeaveQuiz = true
            }
        }
    }
    
    func endQuiz() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users")

        partyRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error starting quiz: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }

            for document in documents {
                document.reference.updateData(["inQuiz": false]) { error in
                    if let error = error {
                        print("Error updating inQuiz status: \(error.localizedDescription)")
                    } else {
                        print("User inQuiz status updated")
                    }
                }
                document.reference.updateData(["playerScore": 0]) { error in
                    if let error = error {
                        print("Error updating playerScore status: \(error.localizedDescription)")
                    } else {
                        print("User playerScore status updated")
                    }
                }
            }
        }
    }
}

struct LeaderBoardView: View {
    @StateObject var viewModel: LeaderBoardViewModel
    @State private var navigateToLeaveQuizView = false
    
    init(partyCode: String) {
        _viewModel = StateObject(wrappedValue: LeaderBoardViewModel(partyCode: partyCode))
    }
    
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .padding()
            
            List {
                let sortedUsers = viewModel.users.sorted(by: { $0.playerScore > $1.playerScore })
                let highestScore = sortedUsers.first?.playerScore
                
                ForEach(sortedUsers, id: \.id) { user in
                    HStack {
                        Text(user.username)
                        Spacer()
                        Text("\(user.playerScore) correct answers")
                        if user.playerScore == highestScore {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding()
            
            if viewModel.currentUser?.isLeader == true {
                Button(action: {
                    viewModel.endQuiz()
                }) {
                    Text("Return to Menu")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onChange(of: viewModel.navigateLeaveQuiz) { navigateLeaveQuiz in
            if navigateLeaveQuiz {
                navigateToLeaveQuizView = true
            }
        }
        .fullScreenCover(isPresented: $navigateToLeaveQuizView) {
            PartyView(partyCode: viewModel.partyCode)
        }
    }
}

#Preview {
    LeaderBoardView(partyCode: "testCode")
}
