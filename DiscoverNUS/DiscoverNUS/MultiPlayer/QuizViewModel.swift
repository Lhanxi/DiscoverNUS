//
//  QuizViewModel.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 11/7/24.
//

import Foundation
import SwiftUI
import Combine

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
    @Published var timeRemaining: Int = 5
    @Published var transitionTime: Int = 10
    @Published var scores: [String: Int] = [:]
    @Published var showLeaderBoard: Bool = false
    
    var timer: AnyCancellable?
    var currentPlayer: String = "Player 1"
    
    //Update to FireBase in the future
    @Published var questions: [QuestionModel] = [
        QuestionModel(id: UUID(), question: "Question 1", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), //1
        QuestionModel(id: UUID(), question: "Question 2", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1), //2
        QuestionModel(id: UUID(), question: "Question 3", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 2), //3
        QuestionModel(id: UUID(), question: "Question 4", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 3), //4
        QuestionModel(id: UUID(), question: "Question 5", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), //5
        QuestionModel(id: UUID(), question: "Question 6", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1), //6
        QuestionModel(id: UUID(), question: "Question 7", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 2), //7
        QuestionModel(id: UUID(), question: "Question 8", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 3), //8
        QuestionModel(id: UUID(), question: "Question 9", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 0), //9
        QuestionModel(id: UUID(), question: "Question 10", answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"], correctAnswer: 1) //10
    ]
    
    func startQuiz() {
        startTimer()
    }
    
    func startTimer() {
        timer?.cancel()
        timeRemaining = 5
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
            if isCorrect == true {
                scores[currentPlayer, default: 0] += 1
            }
        }
        self.startTransitionTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.moveToNextQuestion()
        }
    }
    
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else {return}
        selectedAnswerIndex = index
        if self.timeRemaining == 0 {
            self.moveToNextQuestion()
        }
    }
    
    func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1{
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            isCorrect = nil
            startTimer()
        } else {
            showLeaderBoard = true
        }
    }
}
