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

struct QuestionModel {
    var id: UUID
    var question: String
    var answers: [String]
    var correctAnswer: Int
}

final class QuizViewModel: ObservableObject {
    
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var isCorrect: Bool? = nil
    @Published var timeRemaining: Int = 10
    @Published var transitionTime: Int = 10
    @Published var showLeaderBoard: Bool = false
    
    @Published var partyCode: String
    
    var timer: AnyCancellable?
    
    // Update to FireBase in the future
    @Published var questions: [QuestionModel] = [
        QuestionModel(id: UUID(), question: "Question 1", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), // 1
        QuestionModel(id: UUID(), question: "Question 2", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1), // 2
        QuestionModel(id: UUID(), question: "Question 3", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 2), // 3
        QuestionModel(id: UUID(), question: "Question 4", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 3), // 4
        QuestionModel(id: UUID(), question: "Question 5", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), // 5
        QuestionModel(id: UUID(), question: "Question 6", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1), // 6
        QuestionModel(id: UUID(), question: "Question 7", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 2), // 7
        QuestionModel(id: UUID(), question: "Question 8", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 3), // 8
        QuestionModel(id: UUID(), question: "Question 9", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), // 9
        QuestionModel(id: UUID(), question: "Question 10", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1) // 10
    ].shuffled()
    
    init(partyCode: String) {
        self.partyCode = partyCode
    }
    
    var anySelected: Bool {
        return selectedAnswerIndex != nil
    }
    
    func startQuiz() {
        startTimer()
    }
    
    func startTimer() {
        timer?.cancel()
        timeRemaining = 10
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
        transitionTime = 10
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
        
        // Check if the document exists
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document exists, update the player score
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
                // Document does not exist, handle the error
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
