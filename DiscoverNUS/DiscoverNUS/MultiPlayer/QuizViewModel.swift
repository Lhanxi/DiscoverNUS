//
//  QuizViewModel.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 11/7/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

struct QuestionModel: Identifiable {
    var id: String
    var question: String
    var answers: [String]
    var correctAnswer: Int
}

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

final class QuizViewModel: ObservableObject {
    
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var isCorrect: Bool? = nil
    @Published var timeRemaining: Int = 1
    @Published var transitionTime: Int = 1
    @Published var showLeaderBoard: Bool = false
    @Published var partyCode: String
    @Published var currentUser: UserRef?
    @Published var questions: [QuestionModel] = []
    @Published var isFetched: Bool = false

    var timer: AnyCancellable?
    
    init(partyCode: String) {
        self.partyCode = partyCode
        fetchPartyQuestions {
            print("fetchPartyQuestions completed, starting quiz")
            self.startQuiz()
        }
    }

    var anySelected: Bool {
        return selectedAnswerIndex != nil
    }

    func fetchPartyQuestions(completion: @escaping () -> Void) {
        print("fetchPartyQuestions")
        let db = Firestore.firestore()
        let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(self.partyCode)
        let questionsCollectionRef = partyRef.collection("questions")

        questionsCollectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching party questions: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                return
            }
            
            let questionSet: [QuestionModel] = documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                let question = data["question"] as? String ?? ""
                let answers = data["answers"] as? [String] ?? []
                let correctAnswer = data["correctAnswer"] as? Int ?? 0
                return QuestionModel(id: id, question: question, answers: answers, correctAnswer: correctAnswer)
            }
            
            print("Fetched \(questionSet.count) questions")
            self.questions = questionSet
            self.isFetched = true
            completion()
        }
    }

    func startQuiz() {
        print("Starting quiz")
        startTimer()
    }
    
    func startTimer() {
        timer?.cancel()
        timeRemaining = 1
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timeRemaining -= 1
                self.showCorrectAnswer()
            }
        }
    }
    
    func startTransitionTimer() {
        timer?.cancel()
        transitionTime = 1
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.transitionTime > 0 {
                self.transitionTime -= 1
            }
        }
    }
    
    func showCorrectAnswer() {
        if selectedAnswerIndex == nil {
            isCorrect = false
        } else {
            isCorrect = (selectedAnswerIndex == questions[currentQuestionIndex].correctAnswer)
            if let isCorrect = isCorrect, isCorrect {
                self.updatePlayerScore()
            }
        }
        self.startTransitionTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.moveToNextQuestion()
        }
    }
    
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else { return }
        selectedAnswerIndex = index
        if self.timeRemaining == 0 {
            self.showCorrectAnswer()
        }
    }
    
    func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            isCorrect = nil
            startTimer()
        } else {
            showLeaderBoard = true
        }
    }
    
    func updatePlayerScore() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("Teams").document("DefaultTeam")
            .collection("Parties").document(partyCode).collection("Users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                userRef.updateData([
                    "playerScore": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        print("Error updating player score: \(error.localizedDescription)")
                    } else {
                        print("Player score successfully updated")
                    }
                }
            } else {
                print("Error updating player score: No document to update")
            }
        }
    }
    
    func updateMultiPlayerScores() {
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
            let db = Firestore.firestore()
            
            db.collection("users").document(userID).updateData([
                "GamesPlayed": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error updating GamesPlayed: \(error.localizedDescription)")
                } else {
                    print("Successfully updated GamesPlayed for user \(userID)")
                }
            }
            
            let partyRef = db.collection("Teams").document("DefaultTeam")
                .collection("Parties").document(partyCode).collection("Users")
            
            partyRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                var highestScore: Int = Int.min
                var highestScoringUserID: String?
                
                for document in documents {
                    let data = document.data()
                    if let playerScore = data["playerScore"] as? Int {
                        if playerScore > highestScore {
                            highestScore = playerScore
                            highestScoringUserID = document.documentID
                        }
                    }
                }
                
                if let highestScoringUserID = highestScoringUserID, highestScoringUserID == userID {
                    db.collection("users").document(highestScoringUserID).updateData([
                        "GamesWon": FieldValue.increment(Int64(1))
                    ]) { error in
                        if let error = error {
                            print("Error updating GamesWon: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated GamesWon for user \(userID)")
                        }
                    }
                }
            }
        } catch {
            print("Error getting authenticated user: \(error.localizedDescription)")
        }
    }
}


