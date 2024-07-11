//
//  QuizView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 11/7/24.
//

import SwiftUI

struct AnswerButton: View {
    var text: String
    var isSelected: Bool
    var isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                if isSelected {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
        }
        .disabled(isSelected)
    }
}

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.questions[viewModel.currentQuestionIndex].question)
        }
        ForEach(0..<viewModel.questions[viewModel.currentQuestionIndex].answers.count, id: \.self) { index in
            AnswerButton(
                text: viewModel.questions[viewModel.currentQuestionIndex].answers[index],
                isSelected: viewModel.selectedAnswerIndex == index,
                isCorrect: viewModel.isCorrect != nil && index == viewModel.questions[viewModel.currentQuestionIndex].correctAnswer,
                onTap: {
                    viewModel.selectAnswer(at: index)
                }
            )
        }
        
        if let isCorrect = viewModel.isCorrect {
            Text(isCorrect ? "Correct" : "Wrong")
                .font(.largeTitle)
                .foregroundColor(isCorrect ? .green : .red)
                .padding()
        }
    }
}

#Preview {
    QuizView()
}
