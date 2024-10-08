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
import CoreImage.CIFilterBuiltins

@MainActor
final class PartyViewModel: ObservableObject {
    @Published var partyCode: String
    @Published var users: [UserRef] = []
    @Published var currentUser: UserRef?
    @Published var isKicked: Bool = false
    @Published var navigateToQuiz: Bool = false
    @Published var questions: [QuestionModel] = []

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
    
    struct QuestionModel: Identifiable {
        var id: String
        var question: String
        var answers: [String]
        var correctAnswer: Int
    }

    init(partyCode: String) {
        self.partyCode = partyCode
        fetchCurrentUser { [weak self] in
            guard let self = self else { return }
            if let currentUser = self.currentUser, currentUser.isLeader {
                print("generateAndStoreQuestions")
                self.generateAndStoreQuestions()
            }
            self.fetchUsers()
        }
    }

    deinit {
        listener?.remove()
        currentUserListener?.remove()
    }

    func fetchCurrentUser(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            completion()
            return
        }

        let userID = user.uid
        let db = Firestore.firestore()
        let userRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode).collection("Users").document(userID)

        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
                completion()
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("Current user document does not exist.")
                completion()
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
            completion()
        }
    }
    
    func generateAndStoreQuestions() {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
        let questionsCollectionRef = partyRef.collection("questions")
        
        // Delete existing questions first (if any)
        questionsCollectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found to delete")
                // Proceed to load new questions even if none exist
                self.loadQuestionsIntoParty(partyRef: partyRef, questionsCollectionRef: questionsCollectionRef)
                return
            }
            
            // Delete existing questions
            let batch = db.batch()
            documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting documents: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted existing questions")
                    // Proceed to load new questions after deletion
                    self.loadQuestionsIntoParty(partyRef: partyRef, questionsCollectionRef: questionsCollectionRef)
                }
            }
        }
    }

    func loadQuestionsIntoParty(partyRef: DocumentReference, questionsCollectionRef: CollectionReference) {
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
        // Load new questions and store them
        db.collection("questions").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            let selectedDocuments = documents.shuffled().prefix(10) // Randomly select 10 questions

            let questions: [QuestionModel] = selectedDocuments.compactMap { doc in
                let data = doc.data()
                let question = data["question"] as? String ?? ""
                let answerOne = data["answerOne"] as? String ?? ""
                let answerTwo = data["answerTwo"] as? String ?? ""
                let answerThree = data["answerThree"] as? String ?? ""
                let correctAnswer = data["correctAnswer"] as? String ?? ""
                let answers = [answerOne, answerTwo, answerThree, correctAnswer].shuffled()
                let correctAnswerIndex = answers.firstIndex(of: correctAnswer) ?? 0
                return QuestionModel(id: doc.documentID, question: question, answers: answers, correctAnswer: correctAnswerIndex)
            }

            // Run transaction to store new questions
            db.runTransaction({ transaction, errorPointer in
                do {
                    let partySnapshot = try transaction.getDocument(partyRef)

                    guard partySnapshot.exists else {
                        throw NSError(domain: "PartyDocumentNotExist", code: 0, userInfo: nil)
                    }
                    
                    print("Loaded \(questions.count) questions")
                    
                    for question in questions {
                        let questionData: [String: Any] = [
                            "id": question.id,
                            "question": question.question,
                            "answers": question.answers,
                            "correctAnswer": question.correctAnswer
                        ]

                        let questionDocRef = questionsCollectionRef.document(question.id)
                        transaction.setData(questionData, forDocument: questionDocRef)
                    }

                    return nil // Return nil to indicate successful transaction
                } catch {
                    errorPointer?.pointee = error as NSError // Set the error pointer if there's an error
                    return nil // Return nil to indicate failure
                }
            }) { _, error in
                if let error = error {
                    print("Transaction failed: \(error.localizedDescription)")
                } else {
                    print("Successfully stored game questions")
                }
            }
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

            var fetchedUsers = documents.compactMap { document in
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

            // Sort users: leader at the top, then alphabetically
            if let leader = fetchedUsers.first(where: { $0.isLeader }) {
                fetchedUsers.removeAll { $0.id == leader.id }
                fetchedUsers.sort { $0.username < $1.username }
                fetchedUsers.insert(leader, at: 0)
            } else {
                fetchedUsers.sort { $0.username < $1.username }
            }

            self.users = fetchedUsers
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
        
        usersCollectionRef.document(userID).delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User successfully kicked")
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

    func generateQRCode(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

struct PartyView: View {
    @StateObject private var viewModel: PartyViewModel
    @State private var navigateToJoinPartyView = false
    @State private var navigateToJoinQuizView = false
    @State var showSignInView: Bool
    @State var playerInfo: Player

    init(partyCode: String, showSignInView: Bool, playerInfo:Player) {
        _viewModel = StateObject(wrappedValue: PartyViewModel(partyCode: partyCode))
        _playerInfo = State(initialValue: playerInfo)
        _showSignInView = State(initialValue: showSignInView)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("\(viewModel.users.count)/4 Players")
                    .font(.title)
                    .padding(.top)

                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 350, height: 250)
                        .shadow(color: .gray, radius: 10, x: 10, y: 10) // Shadow on right and bottom
                        .shadow(color: .clear, radius: 5, x: -5, y: -5) // No shadow on top and left
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 2, y: 2)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        )

                    VStack {
                        if let qrCodeImage = viewModel.generateQRCode(from: viewModel.partyCode) {
                            Image(uiImage: qrCodeImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .padding()
                        }

                        Text("Party Code: \(viewModel.partyCode)")
                            .font(.headline)
                            .padding(.bottom)
                    }
                }

                List(viewModel.users, id: \.id) { user in
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.gray.opacity(0.2))
                            .frame(maxWidth: 350, minHeight: 40)
                            .padding(.horizontal, 8)

                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .padding(.leading, 12)

                            Text(user.username)
                                .font(.body)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer()

                            if user.isLeader {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .padding(.trailing, 12)
                            } else {
                                if viewModel.currentUser?.isLeader == true {
                                    Button(action: {
                                        viewModel.kickUser(userID: user.id)
                                    }) {
                                        Text("Kick")
                                            .foregroundColor(.red)
                                            .padding(.trailing, 12)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .background(Color.white)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())

                Spacer()

                if viewModel.currentUser?.isLeader == true && viewModel.users.count > 1{
                    Button(action: {
                        viewModel.startQuiz()
                    }) {
                        Text("Start Quiz")
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
                }

                Button(action: {
                    viewModel.leaveParty()
                    navigateToJoinPartyView = true
                }) {
                    Text("Leave Party")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: 250)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
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
                MultiPlayerView(showSignInView: $showSignInView, playerInfo: playerInfo)
            }
            .fullScreenCover(isPresented: $navigateToJoinQuizView) {
                QuizView(partyCode: viewModel.partyCode, showSignInView: showSignInView, playerInfo: playerInfo)
            }
        }
        .navigationBarHidden(true) // Hides the navigation bar
    }
}
