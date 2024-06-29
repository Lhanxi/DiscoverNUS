//
//  RootView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//



import SwiftUI
import FirebaseAuth

struct RootView: View {
    @State private var showSignInView: Bool = false
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    HomePage(showSignInView: $showSignInView, playerInfo: RootView.getUserInfo())
                }
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
    
    /*
     static func getUserInfo() -> Player {
     var player: Player?
     let semaphore = DispatchSemaphore(value: 0)
     
     AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: Auth.auth().currentUser!.uid) { result in
     player = result
     semaphore.signal()
     }
     
     semaphore.wait()
     
     return player!
     }}
     */
    
    //temp test
    static func getUserInfo() -> Player {
        return Player(id: "test", level:1, image: Image(systemName: "default_person"), quests:["hi", "test", "yes"], multiplayerGamesPlayed: 0, multiplayerGamesWon: 0)
    }
}
