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
    @StateObject private var viewModel = CreatePartyViewModel()
    @State private var navigateToCreatePartyView = false
    
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
                        NavigationLink(destination: CreatePartyView(viewModel: viewModel), isActive: $navigateToCreatePartyView) {
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
                        
                        NavigationLink(destination: JoinPartyView()) {
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
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 17) & 0xFF, (int >> 4 * 17) & 0xFF, (int * 17) & 0xFF)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MultiPlayerView()
}





