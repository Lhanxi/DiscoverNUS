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
final class LeaderBoardViewModel: ObservableObject {
    @Published var users: [UserRef] = []
    @Published var navigateLeaveQuiz: Bool = false
    @Published var currentUser: UserRef?
    @Published var partyCode: String
    @Published var remainingTime: Int = 10
    
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
    private var timerCancellable: AnyCancellable?
    
    init(partyCode: String) {
        self.partyCode = partyCode
        fetchCurrentUser()
        fetchUsers()
        startTimer()
    }
    
    deinit {
        listener?.remove()
        timerCancellable?.cancel()
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
    
    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.timerCancellable?.cancel()
                    self.endQuiz()
                    self.navigateLeaveQuiz = true
                }
            }
    }
    
    func endQuiz() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users")

        partyRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error ending quiz: \(error.localizedDescription)")
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
    @State var showSignInView: Bool
    @State var playerInfo: Player
    
    init(partyCode: String, showSignInView: Bool, playerInfo: Player) {
        _viewModel = StateObject(wrappedValue: LeaderBoardViewModel(partyCode: partyCode))
        _playerInfo = State(initialValue: playerInfo)
        _showSignInView = State(initialValue: showSignInView)
    }
    
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .padding(.top) // Only apply padding to the top
                .padding([.leading, .trailing]) // Apply padding to the left and right edges
            
            Image(.leaderboard)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding()
            
            List {
                let sortedUsers = viewModel.users.sorted(by: { $0.playerScore > $1.playerScore })
                let rankedUsers = assignRanks(to: sortedUsers)
                
                ForEach(rankedUsers, id: \.user.id) { rankedUser in
                    HStack {
                        ZStack(alignment: .topLeading) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.leading, 10)
                            if rankedUser.rank == 1 {
                                Image(systemName: "crown.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color(hex: "#FFAA00"))
                                    .rotationEffect(.degrees(-35))
                                    .offset(x: -8, y: -10)
                            }
                        }
                        Text(rankedUser.user.username)
                        Spacer()
                        Text("\(rankedUser.user.playerScore) \(rankedUser.user.playerScore == 1 ? "Pt" : "Pts")")
                    }
                    .padding()
                    .background(rankBackgroundColor(rank: rankedUser.rank))
                    .cornerRadius(8)
                }
                .listRowSeparator(.hidden)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .listStyle(PlainListStyle())
            
            Text("Returning to menu in: \(viewModel.remainingTime) seconds")
                .font(.headline)
                .foregroundColor(.red)
                .padding()
            
            if viewModel.currentUser?.isLeader == true {
                Button(action: {
                    viewModel.endQuiz()
                }) {
                    Text("Return to Menu")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .frame(height: 55)
                        .frame(maxWidth: 250)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#5687CE"), Color(hex: "#5687CE").opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
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
            PartyView(partyCode: viewModel.partyCode, showSignInView: showSignInView, playerInfo: playerInfo)
        }
    }
    
    private func assignRanks(to users: [LeaderBoardViewModel.UserRef]) -> [(user: LeaderBoardViewModel.UserRef, rank: Int)] {
        var rankedUsers: [(user: LeaderBoardViewModel.UserRef, rank: Int)] = []
        var currentRank = 0
        var lastScore: Int? = nil
        
        for user in users {
            if lastScore == nil || user.playerScore < lastScore! {
                currentRank += 1
                lastScore = user.playerScore
            }
            rankedUsers.append((user: user, rank: currentRank))
        }
        
        return rankedUsers
    }
    
    private func rankBackgroundColor(rank: Int) -> Color {
        switch rank {
        case 1:
            return Color(hex: "#FDD700")
        case 2:
            return Color(hex: "#C0C0C0")
        case 3:
            return Color(hex: "#CD7F32")
        default:
            return Color(hex: "#EDEDED")
        }
    }
}

