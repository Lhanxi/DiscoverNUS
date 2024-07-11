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
    

    
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else {return}
        selectedAnswerIndex = index
        isCorrect = (index == questions[currentQuestionIndex].correctAnswer)
    }
    
    
    
}
