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
                    if isCorrect {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .disabled(isSelected)
    }
}

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel
    
    init(partyCode: String) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(partyCode: partyCode))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.showLeaderBoard {
                LeaderBoardView(partyCode: viewModel.partyCode)
                    .onAppear {
                        viewModel.updateMultiPlayerScores()
                    }
            } else {
                VStack {
                    Text(viewModel.questions[viewModel.currentQuestionIndex].question)
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
                    
                    if viewModel.timeRemaining >= 0 {
                        Text("Time Remaining: \(viewModel.timeRemaining)")
                            .font(.headline)
                            .padding()
                    } else {
                        Text("Moving onto next question: \(viewModel.transitionTime)")
                            .font(.headline)
                            .padding()
                    }
                    
                    if viewModel.timeRemaining <= 0, let isCorrect = viewModel.isCorrect {
                        Text(isCorrect ? "Correct" : "Wrong")
                            .font(.largeTitle)
                            .foregroundColor(isCorrect ? .green : .red)
                            .padding()
                    }
                }
                .padding()
                .onAppear {
                    viewModel.startQuiz()
                }
            }
        }
    }
}

#Preview {
    QuizView(partyCode: "testCode")
}
