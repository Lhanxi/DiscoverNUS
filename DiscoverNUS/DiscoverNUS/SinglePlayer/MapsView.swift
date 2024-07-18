//
//  SinglePlayerView.swift
//  DiscoverNUS
//
//  Created by Leung Han Xi on 16/7/24.
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
    @ObservedObject var questManager: QuestArrayManager
    
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
        
        /*
        playerLocation.setup()
        playerMarker.iconView = playerMarkerView()
        
        //might want to see if ! is the right thing to do (force unwrap)
        playerMarker.position = playerLocation.userLocation!.coordinate
        playerMarker.map = mapView
         */
        
        for quest in questManager.quests {
            let marker = GMSMarker()
            marker.position = quest.position
            marker.title = quest.name
            marker.userData = quest
            marker.map = mapView
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.animate(with: GMSCameraUpdate.fit(boundRegion, withPadding:0))
        
        mapView.clear()
                
        for quest in questManager.quests {
            let marker = GMSMarker()
            marker.position = quest.position
            marker.title = quest.name
            marker.userData = quest
            marker.map = mapView
        }
        
        /*
        playerLocation.setup()
        playerMarker.iconView = playerMarkerView()
        
        //might want to see if ! is the right thing to do (force unwrap)
        playerMarker.position = playerLocation.userLocation!.coordinate
        playerMarker.map = mapView
         */
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
class QuestArrayManager: ObservableObject {
    @Published var quests: [Quest] = []
    
    func add(questList: [Quest]) -> Void {
        self.quests += questList
    }
}

