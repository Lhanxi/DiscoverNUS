//
//  QuestManager.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 7/6/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import GoogleMaps

struct Quest {
    let name: String
    let position: CLLocationCoordinate2D
    let title: String
    let image: UIImage
    let description: String
}

class QuestManager {
    static func getQuest(questId: String) {
        
    }
}
