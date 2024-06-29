//
//  ForgotPasswordView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 4/6/24.
//

import SwiftUI
import Network

@MainActor
final class ForgotPassWordViewModel: ObservableObject {
    @Published var email = ""
    @Published var alertMessage: String? = nil
    @Published var showAlert: Bool = false
    
    func resetPassword() async {
        do {
            try await AuthenticationManager.shared.resetPassword(email: email)
            alertMessage = "A password reset email has been sent!"
        } catch {
            alertMessage = error.localizedDescription
        }
        showAlert = true
    }
}

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPassWordViewModel()
    
    var body: some View {
        VStack(spacing: 20)  {
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                    .font(.headline)
                TextField("Email", text: $viewModel.email).autocapitalization(.none).keyboardType(.default)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                    .foregroundColor(.gray)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            }
            Button {
                Task {
                    await viewModel.resetPassword()
                }
                
            } label: {
                HStack {
                    Spacer()
                    Text("Reset Password")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: 150)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Notification"),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }
}

#Preview {
    ForgotPasswordView()
}
