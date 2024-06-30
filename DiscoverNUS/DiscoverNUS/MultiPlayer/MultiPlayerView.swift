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
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.8), Color(red: 1.0, green: 0.7, blue: 0.6)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                
                VStack(spacing: 30) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color.orange)
                        .padding(.top, 60)
                    
                    Text("MultiPlayer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.orange)
                        .padding(.vertical, 20)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                    
                    VStack(spacing: 30) {
                        NavigationLink(destination: CreatePartyView()) {
                            Text("Create Party")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color(red: 1.0, green: 0.5, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        
                        NavigationLink(destination: JoinPartyView()) {
                            Text("Join Party")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(height: 55)
                                .frame(maxWidth: 250)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color(red: 1.0, green: 0.5, blue: 0.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    
                    HStack(spacing: 40) {

                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                            .rotationEffect(.degrees(-45)) // Tilt the icon 45 degrees to the left
                            .offset(y: -100) // Move the icon slightly higher
                        
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                        
                        Image(systemName: "flag.2.crossed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color.orange)
                            .offset(y: -80)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    MultiPlayerView()
}






