//
//  LeaderboardHandler.swift
//  DiscoverNUS
//
//  Created by Xue Ping on 19/7/24.
//

import Foundation
import FirebaseFirestore

struct LeaderBoardPlayer: Identifiable {
    var id: String
    var rank: Int
    var username: String
    var level: Int
    var totalExp: Int
}

struct LeaderBoardMultiPlayer: Identifiable {
    var id: String
    var rank: Int
    var username: String
    var gamesWon: Int
    var winRate: String
}

class LeaderBoardHandler: ObservableObject {
    static func topUsersLevel(completion: @escaping([LeaderBoardPlayer]) -> Void) async throws {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let query = collectionRef.order(by: "level", descending: true).order(by: "exp", descending: true)
            .start(at: [100])
            .end(at: [100])
        var level = 1
        var exp = 0
        
        let querySnapshot = try await query.getDocuments()
        if let document = querySnapshot.documents.first {
            if let retrievedLevel = document["level"] as? Int,
                let retrievedExp = document["exp"] as? Int {
                level = retrievedLevel
                exp = retrievedExp
            }
        }
        
        let mainQuery = collectionRef.order(by: "level", descending: true).order(by: "exp", descending: true).order(by: "username", descending: false).whereField("level", isGreaterThanOrEqualTo: level)
            
        var previousLevel = 0
        var previousExp = 0
        var rankCounter = 1
        var counter = 1
        var leaderboardArray: [LeaderBoardPlayer] = []
        
        let mainSnapshot = try await mainQuery.getDocuments()
        for document in mainSnapshot.documents {
            if let retrievedID = document["id"] as? String,
               let retrievedLevel = document["level"] as? Int,
               let retrievedExp = document["exp"] as? Int,
               let retrievedUsername = document["username"] as? String {
                if counter == 1 {
                    previousLevel = retrievedLevel
                    previousExp = retrievedExp
                    leaderboardArray.append(LeaderBoardPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, level: retrievedLevel, totalExp: LevelSystem.totalExp(level: retrievedLevel, currentExp: retrievedExp)))
                    counter += 1
                } else if retrievedLevel == level && retrievedExp < exp {
                    break
                } else if retrievedLevel == previousLevel && retrievedExp == previousExp {
                    leaderboardArray.append(LeaderBoardPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, level: retrievedLevel, totalExp: LevelSystem.totalExp(level: retrievedLevel, currentExp: retrievedExp)))
                    counter += 1
                } else {
                    previousLevel = retrievedLevel
                    previousExp = retrievedExp
                    rankCounter = counter
                    leaderboardArray.append(LeaderBoardPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, level: retrievedLevel, totalExp: LevelSystem.totalExp(level: retrievedLevel, currentExp: retrievedExp)))
                    counter += 1
                }
            }
        }
        
        completion(leaderboardArray)
    }
    
    static func getCurrentUserLevelRank(userID: String) async throws -> String {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let query = collectionRef.order(by: "level", descending: true).order(by: "exp", descending: true)
            .start(at: [999])
            .end(at: [999])
        var level = 1
        var exp = 0
        
        let querySnapshot = try await query.getDocuments()
        if let document = querySnapshot.documents.first {
            if let retrievedLevel = document["level"] as? Int,
                let retrievedExp = document["exp"] as? Int {
                level = retrievedLevel
                exp = retrievedExp
            }
        }
        
        let mainQuery = collectionRef.order(by: "level", descending: true).order(by: "exp", descending: true).order(by: "username", descending: false).whereField("level", isGreaterThanOrEqualTo: level)
        
        var previousLevel = 0
        var previousExp = 0
        var rankCounter = 1
        var counter = 1
        
        let mainSnapshot = try await mainQuery.getDocuments()
        for document in mainSnapshot.documents {
            if let retrievedID = document["id"] as? String,
               let retrievedLevel = document["level"] as? Int,
               let retrievedExp = document["exp"] as? Int {
                if userID == retrievedID {
                    return "\(rankCounter)"
                }
                if counter == 1 {
                    previousLevel = retrievedLevel
                    previousExp = retrievedExp
                    counter += 1
                } else if retrievedLevel == level && retrievedExp < exp {
                    break
                } else if retrievedLevel == previousLevel && retrievedExp == previousExp {
                    counter += 1
                } else {
                    previousLevel = retrievedLevel
                    previousExp = retrievedExp
                    rankCounter = counter
                    counter += 1
                }
            }
        }
        return "-"
    }
    
    static func topUsersMultiplayer(completion: @escaping([LeaderBoardMultiPlayer]) -> Void) async throws {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let query = collectionRef.order(by: "GamesWon", descending: true).order(by: "GamesPlayed", descending: false)
            .start(at: [100])
            .end(at: [100])
        var gamesWon = 0
        var gamesPlayed = 0
        
        let querySnapshot = try await query.getDocuments()
        if let document = querySnapshot.documents.first {
            if let retrievedGamesWon = document["GamesWon"] as? Int,
                let retrievedGamesPlayed = document["GamesPlayed"] as? Int {
                gamesWon = retrievedGamesWon
                gamesPlayed = retrievedGamesPlayed
            }
        }
        
        let mainQuery = collectionRef.order(by: "GamesWon", descending: true).order(by: "GamesPlayed", descending: false).order(by: "username", descending: false).whereField("GamesWon", isGreaterThanOrEqualTo: gamesWon)
            
        var previousGamesWon = 0
        var previousGamesPlayed = 0
        var rankCounter = 1
        var counter = 1
        var leaderboardArray: [LeaderBoardMultiPlayer] = []
        
        let mainSnapshot = try await mainQuery.getDocuments()
        for document in mainSnapshot.documents {
            if let retrievedID = document["id"] as? String,
               let retrievedGamesWon = document["GamesWon"] as? Int,
               let retrievedGamesPlayed = document["GamesPlayed"] as? Int,
               let retrievedUsername = document["username"] as? String {
                if counter == 1 {
                    previousGamesWon = retrievedGamesWon
                    previousGamesPlayed = retrievedGamesPlayed
                    leaderboardArray.append(LeaderBoardMultiPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, gamesWon: retrievedGamesWon, winRate: WinRateHandler.winRate(gamesWon: retrievedGamesWon, gamesPlayed: retrievedGamesPlayed)))
                    counter += 1
                } else if retrievedGamesWon == gamesWon && retrievedGamesPlayed > gamesPlayed {
                    break
                } else if retrievedGamesWon == previousGamesWon && retrievedGamesPlayed == previousGamesPlayed {
                    leaderboardArray.append(LeaderBoardMultiPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, gamesWon: retrievedGamesWon, winRate: WinRateHandler.winRate(gamesWon: retrievedGamesWon, gamesPlayed: retrievedGamesPlayed)))
                    counter += 1
                } else {
                    previousGamesWon = retrievedGamesWon
                    previousGamesPlayed = retrievedGamesPlayed
                    rankCounter = counter
                    leaderboardArray.append(LeaderBoardMultiPlayer(id: retrievedID, rank: rankCounter, username: retrievedUsername, gamesWon: retrievedGamesWon, winRate: WinRateHandler.winRate(gamesWon: retrievedGamesWon, gamesPlayed: retrievedGamesPlayed)))
                    counter += 1
                }
            }
        }
        
        completion(leaderboardArray)
    }
    
    static func getMultiplayerUserLevelRank(userID: String) async throws -> String {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let query = collectionRef.order(by: "GamesWon", descending: true).order(by: "GamesPlayed", descending: false)
            .start(at: [999])
            .end(at: [999])
        var gamesPlayed = 0
        var gamesWon = 0
        
        let querySnapshot = try await query.getDocuments()
        if let document = querySnapshot.documents.first {
            if let retrievedGamesWon = document["GamesWon"] as? Int,
                let retrievedGamesPlayed = document["GamesPlayed"] as? Int {
                gamesWon = retrievedGamesWon
                gamesPlayed = retrievedGamesPlayed
            }
        }
        
        let mainQuery = collectionRef.order(by: "GamesWon", descending: true).order(by: "GamesPlayed", descending: false).order(by: "username", descending: false).whereField("GamesWon", isGreaterThanOrEqualTo: gamesWon)
            
        var previousGamesWon = 0
        var previousGamesPlayed = 0
        var rankCounter = 1
        var counter = 1
        
        let mainSnapshot = try await mainQuery.getDocuments()
        for document in mainSnapshot.documents {
            if let retrievedID = document["id"] as? String,
               let retrievedGamesWon = document["GamesWon"] as? Int,
               let retrievedGamesPlayed = document["GamesPlayed"] as? Int {
                if userID == retrievedID {
                    return "\(rankCounter)"
                }
                if counter == 1 {
                    previousGamesWon = retrievedGamesWon
                    previousGamesPlayed = retrievedGamesPlayed
                    counter += 1
                } else if retrievedGamesWon == gamesWon && retrievedGamesPlayed > gamesPlayed {
                    break
                } else if retrievedGamesWon == previousGamesWon && retrievedGamesPlayed == previousGamesPlayed {
                    counter += 1
                } else {
                    previousGamesWon = retrievedGamesWon
                    previousGamesPlayed = retrievedGamesPlayed
                    rankCounter = counter
                    counter += 1
                }
            }
        }
        return "-"
    }
}

class WinRateHandler{
    static func winRate(gamesWon: Int, gamesPlayed: Int) -> String {
        if gamesPlayed == 0 {
            return "0%"
        }
        return "\(gamesWon * 100 / gamesPlayed)%"
    }
}
