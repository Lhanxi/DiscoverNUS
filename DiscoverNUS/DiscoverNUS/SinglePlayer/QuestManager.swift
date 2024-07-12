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
import SwiftUI

struct Quest {
    let name: String
    let position: CLLocationCoordinate2D
    let timelimit: Int
    let expGained: Int
    let image: UIImage
    let description: String
}

class QuestManager {
    static func getQuest(imageHandler: ImageHandler, questId: String, completion: @escaping (Quest) -> Void) {
        let db = Firestore.firestore()
        let questRef = db.collection("quests").document(questId)
        
        //should default to an image in firebase system not default person
        var questImage = UIImage(systemName: "star")!
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        imageHandler.getImage(url: "\(questId).jpeg") { image in
            dispatchGroup.leave()
            if let image = image{
                questImage = image
            }
        }
    
        questRef.getDocument {(document, error) in
            if let error = error {
                fatalError("Firestore Error: \(error.localizedDescription)")
            } else if let document = document {
                if document.exists {
                    let data = document.data()
                    let name = data?["name"] as? String
                    let position = data?["position"] as? GeoPoint
                    let timelimit = data?["timelimit"] as? Int
                    let exp = data?["exp"] as? Int
                    let description = data?["description"] as? String
                    let thisQuest = Quest(name: name!,
                                          position: CLLocationCoordinate2D(latitude: position!.latitude, longitude: position!.longitude),
                                          timelimit: timelimit!,
                                          expGained: exp!,
                                          image: questImage,
                                          description: description!)
                    print("completed")
                    dispatchGroup.notify(queue: .main) {
                        completion(thisQuest)
                    }
                } else {
                    //might want to throw error, same as in authentication manager
                    print("empty document")
                }
            } else {
                //might want to throw error
                print("document does not exist")
            }
        }
    }
    
    //this function needs to take into account whether the user has completed the quests or not so a list needs to be stored in each user with quest completed.
    
    //also need error handling later on if there are no more available quests or there are errors (basically minimise the number of dots if there are no more quests)
    
    ///daily quest logic might need new implementation cuz need to change daily? and is repetitive. this should be only for main quests
    
    //need prevent same quest from repeting also in the future
    static func newQuest(count: Int, playerInfo: Player, completion: @escaping(Player) -> Void) {
        let db = Firestore.firestore()
        let questCollection = db.collection("quests")
        var questIDArray: [String] = []
        var playerInfo: Player = playerInfo
        var count = count
        
        questCollection.getDocuments { querySnapshot, error in
            if let error = error {
                //prolly throw some error here later on
                print("error getting quest info")
            } else {
                var indexArray: [Int] = []
                
                for quest in querySnapshot!.documents {
                    questIDArray.append(quest.documentID)
                }
                
                while count < 3 {
                    if questIDArray.count == indexArray.count {
                        break
                    }
                    
                    while true {
                        let index: Int = Int.random(in: 0..<questIDArray.count)
                        if !indexArray.contains(index) {
                            indexArray.append(index)
                            playerInfo.quests.append(questIDArray[index])
                            break
                        }
                    }
                    count += 1
                }
                
                let userRef = db.collection("users").document(playerInfo.id!)
                
                let data: [String: Any] = [
                    "id": playerInfo.id,
                    "level": playerInfo.level,
                    "username": playerInfo.username,
                    "quests": playerInfo.quests,
                    "GamesPlayed": playerInfo.multiplayerGamesPlayed,
                    "GamesWon": playerInfo.multiplayerGamesWon
                ]
                
                userRef.setData(data) { error in
                    if let error = error {
                        //throw error in the future
                        print("error")
                    } else {
                        completion(playerInfo)
                    }
                }
            }
        }
    }
}
