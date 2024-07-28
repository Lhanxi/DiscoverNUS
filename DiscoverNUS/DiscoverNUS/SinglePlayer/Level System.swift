//
//  Level System.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 12/7/24.
//

import Foundation
import FirebaseFirestore

class LevelSystem {
    static var levelUp: Bool = false
    
    static func expToNext(level: Int) -> Int {
        return 50 * level + 500
    }
    
    static func totalExp(level: Int, currentExp: Int) -> Int {
        let level = level - 1
        return 500 * level +  level * (level + 1) * 25 + currentExp
    }
    
    static func expGainManager(userID: String, level: Int, expGained: Int, currentExp: Int, questID: String, questIDArray: [String], completion: @escaping (Error?) -> Void) {
        var expTotal = expGained + currentExp
        var level = level
        while expTotal >= expToNext(level: level) {
            expTotal -= expToNext(level: level)
            level += 1
            LevelSystem.levelUp = true
        }
        
        var removedQuestArray = questIDArray
        if let index = removedQuestArray.firstIndex(of: questID) {
            removedQuestArray.remove(at: index)
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.updateData(["level": level, "exp": expTotal, "quests": removedQuestArray]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
