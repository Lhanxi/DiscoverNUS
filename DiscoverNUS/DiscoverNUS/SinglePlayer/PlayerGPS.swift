//
//  HomePageManager.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import Foundation
import Firebase
import CoreLocation
import SwiftUI

//GPS Handler
class PlayerLocation: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var userLocation: CLLocation?
    private let manager = CLLocationManager()
    
    func setup() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        //update info plist later (permissions list)
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
             userLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        //throw error
        print("Error: \(error.localizedDescription)")
    }
}
