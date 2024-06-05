//
//  SignInGoogle.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 5/6/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

@MainActor
final class SignInGoogle {
    func signIn() async throws -> GoogleSignInResultModel{
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
