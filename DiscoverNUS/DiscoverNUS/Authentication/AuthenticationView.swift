//
//  AuthenticationView.swift
//  SwiftFireBase
//
//  Created by Leung Han Xi on 1/6/24.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    var body: some View {
        VStack(spacing: 20) {
            
            Text("DiscoverNUS")
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .center)
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: 250)
                    .background(Color.orange)
                    .cornerRadius(20)
            }
            
            NavigationLink {
                SignUpEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(Color.orange)
                    .frame(height: 55)
                    .frame(maxWidth: 250)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange, lineWidth: 2)
                    )
            }
            Spacer()
        }
        .padding()
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
