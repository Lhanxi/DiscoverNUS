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
    let title: String
    let image: UIImage
    let description: String
}

class QuestManager {
    static func getQuest(imageHandler: ImageHandler, questId: String, completion: @escaping (Quest) -> Void) {
        let db = Firestore.firestore()
        let questRef = db.collection("quests").document(questId)
        
        //should default to an image in firebase system not default person
        var questImage = UIImage(imageLiteralResourceName: "default_person")
        imageHandler.getImage(url:/*path here with id */"temp") { image in
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
                    if let name = data?["name"] as? String,
                       let position = data?["position"] as? CLLocationCoordinate2D,
                       let title = data?["title"] as? String,
                       let description = data?["description"] as? String {
                        let thisQuest = Quest(name: name,
                                              position: position,
                                              title: title,
                                              image: questImage,
                                              description: description)
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
                while count < 3 {
                    for quest in querySnapshot!.documents {
                        questIDArray.append(quest.documentID)
                    }
                    
                    let index: Int = Int.random(in: 0..<questIDArray.count)
                    
                    playerInfo.quests.append(questIDArray[index])
                    
                    count += 1
                }
                
                let userRef = db.collection("users").document(playerInfo.id!)
                
                let data: [String: Any] = [
                    "id": playerInfo.id,
                    "level": playerInfo.level,
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
