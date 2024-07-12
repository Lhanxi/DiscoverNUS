//
//  RootView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//



import SwiftUI
import FirebaseAuth

@MainActor
final class RootViewModel: ObservableObject {
    @Published var playerInfo: Player?
    @Published var showSignInView: Bool = false
    
    func loadUserInfo() async {
        do {
            if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
                self.showSignInView = false
                self.playerInfo = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: authUser.uid)
            } else {
                self.showSignInView = true
            }
        } catch {
            print("Error loading user info: \(error.localizedDescription)")
        }
    }
}


struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    
    var body: some View {
        ZStack {
            if !viewModel.showSignInView {
                if let playerInfo = viewModel.playerInfo {
                    if playerInfo.username.count != 0 {
                        NavigationStack {
                            HomePage(showSignInView: $viewModel.showSignInView, playerInfo: playerInfo)
                        }
                        .navigationBarHidden(true)
                    } else {
                        NavigationStack {
                            CreateUsername(showSignInView: $viewModel.showSignInView, playerInfo: playerInfo)
                        }
                        .navigationBarHidden(true)
                    }
                } else {
                    Text("Loading...")
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadUserInfo()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $viewModel.showSignInView)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RootView()
}
