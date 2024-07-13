//
//  PartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 20/6/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class PartyViewModel: ObservableObject {
    @Published var partyCode: String
    @Published var users: [UserRef] = []
    @Published var currentUser: UserRef?
    @Published var isKicked: Bool = false
    @Published var navigateToQuiz: Bool = false

    private var listener: ListenerRegistration?
    private var currentUserListener: ListenerRegistration?

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

    init(partyCode: String) {
        self.partyCode = partyCode
        fetchCurrentUser()
        fetchUsers()
    }

    deinit {
        listener?.remove()
        currentUserListener?.remove()
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

            self.listenForKickedStatus()
            self.listenForQuizStatus()
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

            self.updateCurrentUserStatus()
        }
    }

    func updateCurrentUserStatus() {
        guard let currentUserID = self.currentUser?.id else { return }

        if let currentUserIndex = self.users.firstIndex(where: { $0.id == currentUserID }) {
            self.currentUser?.isLeader = self.users[currentUserIndex].isLeader
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
        guard let userID = self.currentUser?.id else {
            print("Error: No current user")
            return
        }

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

        usersCollectionRef.document(userID).updateData(["isKicked": true]) { error in
            if let error = error {
                print("Error updating isKicked status: \(error.localizedDescription)")
            } else {
                print("User isKicked status updated")
            }
        }
    }

    func startQuiz() {
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
                document.reference.updateData(["inQuiz": true]) { error in
                    if let error = error {
                        print("Error updating inQuiz status: \(error.localizedDescription)")
                    } else {
                        print("User inQuiz status updated")
                    }
                }
            }
        }
    }

    func listenForKickedStatus() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users").document(userID)

        currentUserListener = userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error listening for kicked status: \(error.localizedDescription)")
                return
            }

            guard let document = documentSnapshot, let data = document.data() else {
                print("No document found for current user")
                return
            }

            if let isKicked = data["isKicked"] as? Bool, isKicked {
                self.isKicked = true
            }
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

            if let inQuiz = data["inQuiz"] as? Bool, inQuiz {
                self.navigateToQuiz = true
            }
        }
    }
}

struct PartyView: View {
    @StateObject private var viewModel: PartyViewModel
    @State private var navigateToJoinPartyView = false
    @State private var navigateToJoinQuizView = false

    init(partyCode: String) {
        _viewModel = StateObject(wrappedValue: PartyViewModel(partyCode: partyCode))
    }

    var body: some View {
        VStack {
            Text("The Party Code is: \(viewModel.partyCode)")
                .padding()

            List(viewModel.users) { user in
                HStack {
                    Text(user.username)
                    Spacer()
                    if user.isLeader {
                        Text("(Leader)")
                            .foregroundColor(.blue)
                    } else {
                        if viewModel.currentUser?.isLeader == true {
                            Button(action: {
                                viewModel.kickUser(userID: user.id)
                            }) {
                                Text("Kick")
                                    .foregroundColor(.red)
                            }
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

            if viewModel.currentUser?.isLeader == true {
                Button(action: {
                    viewModel.startQuiz()
                }) {
                    Text("Start Quiz")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
        }
        .onChange(of: viewModel.isKicked) { isKicked in
            if isKicked {
                navigateToJoinPartyView = true
            }
        }
        .onChange(of: viewModel.navigateToQuiz) { navigateToQuiz in
            if navigateToQuiz {
                navigateToJoinQuizView = true
            }
        }
        .fullScreenCover(isPresented: $navigateToJoinPartyView) {
            MultiPlayerView()
        }
        .fullScreenCover(isPresented: $navigateToJoinQuizView) {
            QuizView(partyCode: viewModel.partyCode)
        }
    }
}

#Preview {
    PartyView(partyCode: "testCode")
}
