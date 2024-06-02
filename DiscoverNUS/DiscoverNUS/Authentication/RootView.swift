//
//  RootView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//



import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = true
    var body: some View {
        ZStack {
            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
