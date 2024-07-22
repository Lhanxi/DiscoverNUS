//
//  MultiPlayerView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 17/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MultiPlayerView: View {
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @StateObject private var viewModel = CreatePartyViewModel()
    @State private var navigateToCreatePartyView = false
    @State private var navigateToPlayView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("Map")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color.orange)
                        .padding(.top, 60)
                    
                    Text("Multiplayer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.orange)
                        .padding(.vertical, 20)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                    
                    VStack(spacing: 30) {
                        NavigationLink(destination: CreatePartyView(viewModel: viewModel, showSignInView: showSignInView, playerInfo: playerInfo), isActive: $navigateToCreatePartyView) {
                            Button(action: {
                                Task {
                                    await viewModel.createParty()
                                    navigateToCreatePartyView = true
                                }
                            }) {
                                Text("Create Party")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                                    .frame(height: 55)
                                    .frame(maxWidth: 250)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#5687CE"), Color(hex: "#5687CE").opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                        
                        NavigationLink(destination: JoinPartyView(showSignInView: showSignInView, playerInfo: playerInfo)) {
                            Text("Join Party")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarItems(leading: Button(action: {
                navigateToPlayView = true
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Back")
                    .foregroundColor(.blue)
            })
            .background(
                NavigationLink(destination: PlayView(showSignInView: $showSignInView, playerInfo: playerInfo), isActive: $navigateToPlayView) {
                    EmptyView()
                }
            )
        }
        .navigationBarHidden(true)
    }
}






