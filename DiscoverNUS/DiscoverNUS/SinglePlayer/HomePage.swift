//
//  HomePage.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import SwiftUI
import GoogleMaps
import FirebaseAuth

//basic UI and functions for google maps
struct MapsView: UIViewRepresentable {
    var quests: (Quest, Quest, Quest)
    let boundCoords = (south: 1.28000, west: 103.76711, north: 1.30239, east: 103.78788)
    let boundRegion = GMSCoordinateBounds(
        coordinate: CLLocationCoordinate2D(latitude: 1.28000, longitude: 103.76711),
        coordinate: CLLocationCoordinate2D(latitude: 1.30239, longitude: 103.78788))
    
    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: 1.29691, longitude: 103.77648, zoom: 15)
        
        return GMSMapView(options:options)
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.animate(with: GMSCameraUpdate.fit(boundRegion, withPadding:0))
    }
}

//Homepage UI + functions
struct HomePage: View {
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            MapsView(quests: self.getUserQuests())
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    PlayerModelView(showSignInView: $showSignInView)
                        .padding(.trailing, 10)
                }
                Spacer()
                HStack {
                    Button(action: {
                        //play multiplayer
                    }) {
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
        }
    }
    
    //get relevant user info from firebase and pass to the relevant views
    
    //pass in tuple of quests and then pin the quests on google maps
    //dynamically change the number of allowed quests later
    func getUserQuests() -> (Quest, Quest, Quest) {
        //placeholder before editing database
    }
}
