//
//  QuestView.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct QuestView: View {
    let quest: Quest
    @Binding var showSignInView: Bool
    var playerInfo: Player
    @Binding var isPresented: Bool  // Binding to control visibility
    
    @State private var dragOffset: CGSize = .zero  // State to track drag offset
    @StateObject private var playerLocation = PlayerLocation()  // Track player's location
    
    var body: some View {
        VStack {
            // Small horizontal line for pull-down action
            Rectangle()
                .frame(width: 60, height: 5)
                .foregroundColor(.gray)
                .cornerRadius(3)
                .padding(.top, 8)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.dragOffset = value.translation
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                self.isPresented = false
                            }
                            self.dragOffset = .zero
                        }
                )
            
            Image(uiImage: quest.image)
                .resizable()
                .frame(height: 200) // Adjust height as needed
                .frame(width: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 12)
            
            VStack(spacing: 10) {
                HStack {
                    Text(quest.name)
                        .font(.title2)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 15))
                    
                    Text("+\(quest.expGained) EXP")
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                        .padding(.trailing, 20)
                    
                    Image(systemName: "hourglass")
                        .foregroundColor(.black)
                        .font(.system(size: 15))
                    
                    Text("\(quest.timelimit) secs")
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                    Spacer()
                }
                HStack {
                    // Directions button using Google Maps
                    Button(action: {
                        navigateToQuest()
                    }) {
                        HStack {
                            Image(systemName: "arrow.turn.up.right")
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                            
                            Text("Directions")
                                .fontWeight(.bold)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .frame(width: 140)
                        .background(Color.blue) 
                        .cornerRadius(30)
                    }
                    .padding(.trailing, 10)
                    
                    NavigationLink(destination: {
                        StartQuest(quest: quest, timeLimit: quest.timelimit, showSignInView: $showSignInView, playerInfo: playerInfo)
                    }) {
                        HStack {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                            
                            Text("Start")
                                .fontWeight(.bold)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .frame(width: 90)
                        .background(Color.orange)
                        .cornerRadius(30)
                    }
                    Spacer()
                }
  
            }
            .frame(width: 300)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .offset(y: dragOffset.height)  // Apply drag offset
        .padding(.bottom, 20)
        .onAppear {
            playerLocation.setup()
        }
    }
    
    private func navigateToQuest() {
        guard let userLocation = playerLocation.userLocation else {
            print("Current location not available")
            return
        }
        
        let questLocation = quest.position
        let googleMapsUrl = "comgooglemaps://?saddr=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&daddr=\(questLocation.latitude),\(questLocation.longitude)&directionsmode=walking"
        let appleMapsUrl = "http://maps.apple.com/?saddr=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&daddr=\(questLocation.latitude),\(questLocation.longitude)&dirflg=w"
        
        if let url = URL(string: googleMapsUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let url = URL(string: appleMapsUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Neither Google Maps nor Apple Maps are available")
        }
    }
}
