//
//  AuthenticationManager.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import UIKit

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getUserDocument(profile: ImageHandler, userId: String) async throws -> Player {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let userRef = collectionRef.document(userId)
        
        let userImage: UIImage = await profile.getImageAsync(url: userId) ?? UIImage(systemName: "person.fill")!

        let document = try await userRef.getDocument()
        
        if let data = document.data() {
            if let id = data["id"] as? String,
               let level = data["level"] as? Int,
               let quests = data["quests"] as? [String],
               let multiplayerGamesPlayed = data["GamesPlayed"] as? Int,
               let multiplayerGamesWon = data["GamesWon"] as? Int {
                
                return Player(id: id,
                              level: level,
                              image: Image(uiImage: userImage),
                              quests: quests,
                              multiplayerGamesPlayed: multiplayerGamesPlayed,
                              multiplayerGamesWon: multiplayerGamesWon)
            } else {
                throw URLError(.badServerResponse)
            }
        } else {
            let data: [String: Any] = [
                "id": userId,
                "level": 1,
                "quests": [],
                "GamesPlayed": 0,
                "GamesWon": 0
            ]
            
            try await userRef.setData(data)
            return try await getUserDocument(profile: profile, userId: userId)
        }
    }
}

// Sign in for Email
extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
           let auth = Auth.auth()
           try await auth.sendPasswordReset(withEmail: email)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// Sign in for SSO
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential:credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
