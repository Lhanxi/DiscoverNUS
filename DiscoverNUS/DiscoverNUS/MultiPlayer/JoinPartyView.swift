//
//  JoinPartyView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 20/6/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AVFoundation

@MainActor
final class JoinPartyViewModel: ObservableObject {
    @Published var partyCode = ""
    @Published var errorMessage: String?
    
    func joinParty() async {
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            let userID = user.uid
            
            let db = Firestore.firestore()
            
            // Check if the party exists
            let partyRef = db.collection("Teams").document("DefaultTeam").collection("Parties").document(partyCode)
            let partySnapshot = try await partyRef.getDocument()
            
            guard partySnapshot.exists else {
                DispatchQueue.main.async {
                    self.errorMessage = "Party does not exist"
                }
                return
            }
            
            let userRef = partyRef.collection("Users").document(userID)
            try await userRef.setData(["userID": userID, "isLeader": false])
            
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            print("Error joining party: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to join the party: \(error.localizedDescription)"
            }
        }
    }
}

struct JoinPartyView: View {
    @StateObject private var viewModel = JoinPartyViewModel()
    @State private var navigateToPartyView = false
    @State private var isShowingScanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.8), Color(red: 1.0, green: 0.7, blue: 0.6)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    TextField("Enter Party Code", text: $viewModel.partyCode)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(height: 50)
                        .frame(maxWidth: 350)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.joinParty()
                            if viewModel.errorMessage == nil {
                                navigateToPartyView = true
                            }
                        }
                    }) {
                        Text("Join Party")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .frame(height: 55)
                            .frame(maxWidth: 150)
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
                    
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        Text("Scan QR Code")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .frame(height: 55)
                            .frame(maxWidth: 200)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color(red: 0.2, green: 0.5, blue: 1.0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                    NavigationLink(destination: PartyView(partyCode: viewModel.partyCode), isActive: $navigateToPartyView) {
                        EmptyView()
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                QRScannerView(didFindCode: { code in
                    viewModel.partyCode = code
                    isShowingScanner = false
                    Task {
                        await viewModel.joinParty()
                        if viewModel.errorMessage == nil {
                            navigateToPartyView = true
                        }
                    }
                })
            }
        }
    }
}

#Preview {
    JoinPartyView()
}
