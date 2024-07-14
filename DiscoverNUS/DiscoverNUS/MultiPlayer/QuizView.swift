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
    var anySelected: Bool
    var isCorrect: Bool
    var isWrong: Bool
    var isTimeUp: Bool
    let onTap: () -> Void
    
    var body: some View {
           Button(action: {
               onTap()
               print("isSelected: \(isSelected)") // Print isSelected value to console
           }) {
               HStack {
                   Text(text)
                       .foregroundColor(.white)
                       .padding()
                       .frame(maxWidth: 350, alignment: .leading)
                       .background(
                           determineBackgroundColor()
                       )
                       .cornerRadius(10)
                       .overlay(
                           HStack {
                               Spacer()
                               if isTimeUp && isSelected {
                                   if isCorrect {
                                       Image(systemName: "checkmark")
                                           .foregroundColor(.white)
                                           .font(.title2)
                                           .fontWeight(.bold)
                                   } else if isWrong {
                                       Image(systemName: "xmark")
                                           .foregroundColor(.white)
                                           .font(.title2)
                                           .fontWeight(.bold)
                                   }
                               }
                           }
                           .padding(.trailing, 10)
                       )
               }
           }
           .disabled(anySelected)
       }
    
    private func determineBackgroundColor() -> Color {
        if isTimeUp {
            return isCorrect ? Color.green : Color.red
        } else if anySelected && isSelected {
            return Color.blue
        } else if anySelected && !isSelected {
            return Color.orange.opacity(0.3)
        } else {
            return Color.orange
        }
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
                    Text(viewModel.timeRemaining > 0 ? "Time Remaining: \(viewModel.timeRemaining)" : "Next Question in: \(viewModel.transitionTime)")
                        .font(.headline)
                        .padding(.top)
                    
                    ProgressView(value: Double(viewModel.timeRemaining > 0 ? viewModel.timeRemaining : viewModel.transitionTime), total: 1.0)
                        .padding()
                    
                    Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                        .font(.headline)
                        .padding(.top)

                    Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()

                    ForEach(0..<viewModel.questions[viewModel.currentQuestionIndex].answers.count, id: \.self) { index in
                        AnswerButton(
                            text: viewModel.questions[viewModel.currentQuestionIndex].answers[index],
                            isSelected: {
                                if let selectedAnswerIndex = viewModel.selectedAnswerIndex {
                                    return selectedAnswerIndex == index
                                } else {
                                    return false // Handle the case where selectedAnswerIndex is nil
                                }
                            }(),
                            anySelected: viewModel.anySelected,
                            isCorrect: index == viewModel.questions[viewModel.currentQuestionIndex].correctAnswer,
                            isWrong: viewModel.selectedAnswerIndex == index && index != viewModel.questions[viewModel.currentQuestionIndex].correctAnswer,
                            isTimeUp: viewModel.timeRemaining <= 0,
                            onTap: {
                                viewModel.selectAnswer(at: index)
                            }
                        )
                    }
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    viewModel.startQuiz()
                }
            }
        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(partyCode: "testCode")
    }
}
