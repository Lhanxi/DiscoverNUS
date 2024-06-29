//
//  HomePage.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import SwiftUI
import GoogleMaps
import FirebaseAuth
import UIKit

//basic UI and functions for google maps
//debug bound coords later on bah
struct MapsView: UIViewRepresentable {
    @ObservedObject var playerLocation = PlayerLocation()
    @Binding var selectQuest: Bool
    @Binding var selectedQuest: Quest?
    
    var quests: [Quest]
    let boundCoords = (south: 1.28000, west: 103.76711, north: 1.30239, east: 103.78788)
    let boundRegion = GMSCoordinateBounds(
        coordinate: CLLocationCoordinate2D(latitude: 1.28000, longitude: 103.76711),
        coordinate: CLLocationCoordinate2D(latitude: 1.30239, longitude: 103.78788))
    let playerMarker = GMSMarker()
    
    class Coordinator: NSObject, GMSMapViewDelegate {
            var parent: MapsView

            init(_ parent: MapsView) {
                self.parent = parent
            }

            func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
                if let clickedQuest = marker.userData as? Quest {
                    parent.selectQuest.toggle()
                    if parent.selectQuest == true {
                        parent.selectedQuest = clickedQuest
                    }
                }
                return true
            }
        }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: 1.29691, longitude: 103.77648, zoom: 15)
        let mapView = GMSMapView(options:options)
        mapView.delegate = context.coordinator
        
        playerLocation.setup()
        playerMarker.iconView = playerMarkerView()
        
        //might want to see if ! is the right thing to do (force unwrap)
        playerMarker.position = playerLocation.userLocation!.coordinate
        playerMarker.map = mapView
        
        for quest in quests {
            let marker = GMSMarker()
            marker.position = quest.position
            marker.title = quest.title
            marker.userData = quest
            marker.map = mapView
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.animate(with: GMSCameraUpdate.fit(boundRegion, withPadding:0))
        playerMarker.position = playerLocation.userLocation!.coordinate
    }
    
    //customise player marker
    private func playerMarkerView() -> UIView {
        let radius: CGFloat = 50
        let canvas = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        canvas.backgroundColor = .clear
        
        let imageView = UIImageView(frame: canvas.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = radius
        imageView.layer.masksToBounds = true
        //need to add own image and create circular mask in the future
        imageView.image = UIImage(systemName: "default_person")
        
        canvas.addSubview(imageView)
        return canvas
    }
}

//Homepage UI + functions
struct HomePage: View {
    @Binding var showSignInView: Bool
    @State var playerInfo: Player
    @State var selectQuest = false
    @State var selectedQuest: Quest?
    
    var body: some View {
        ZStack {
            MapsView(selectQuest: $selectQuest, selectedQuest: $selectedQuest, quests: self.getUserQuests(questIDList: self.playerInfo.quests))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    PlayerModelView(showSignInView: $showSignInView, playerInfo: playerInfo)
                            .padding(.trailing, 10)
                }
                Spacer()
                HStack {
                    NavigationLink(destination: MultiPlayerView()) {
                                               Text("Play Multiplayer")
                                                   .foregroundColor(Color.black)
                                                   .background(Color.yellow)
                                                   .cornerRadius(5)
                                                   .font(.system(size: 18))
                                                   .padding(10)
                                           }
                                           .padding(30)
                }
            }
            if selectQuest == true {
                if let quest = selectedQuest {
                    QuestView(quest: quest, showSignInView: $showSignInView, playerInfo: playerInfo)
                }
            }
        }.onAppear() {
            if self.playerInfo.quests.count < 3 {
                QuestManager.newQuest(count: self.playerInfo.quests.count, playerInfo: playerInfo) { result in
                    self.playerInfo = result
                }
            }
        }
    }
    
    func getUserQuests(questIDList: [String]) -> [Quest] {
        var quests: [Quest] = []
        
        for questID in questIDList {
            QuestManager.getQuest(imageHandler: ImageHandler(), questId: questID) { result in
                quests.append(result)
            }
        }
        
        return quests
    }
}
