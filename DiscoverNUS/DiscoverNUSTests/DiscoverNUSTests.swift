//
//  DiscoverNUSTests.swift
//  DiscoverNUSTests
//
//  Created by Xue Ping on 26/7/24.
//

import XCTest
import FirebaseFirestore
import Firebase
@testable import DiscoverNUS

final class DiscoverNUSTests: XCTestCase {
    private static var testUser1 = "test_01"
    private static var testUser2 = "test_02"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let expectation = XCTestExpectation(description: "Authentication Test and Inputting test data")

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        let queue = DispatchGroup()
        queue.enter()
        if let user = Auth.auth().currentUser {
            do {
                try AuthenticationManager.shared.signOut()
                queue.leave()
            } catch {
                XCTFail("Failed to sign out: \(error.localizedDescription)")
            }
        } else {
            queue.leave()
        }
        
        let secondQueue = DispatchGroup()
        secondQueue.enter()
        
        //Authentication Test in set up
        queue.notify(queue: .main) {
            let email = "testuser@example.com"
            let password = "testpassword"
            Task{
                do {
                    try await AuthenticationManager.shared.createUser(email: email, password: password)
                    try AuthenticationManager.shared.signOut()
                    try await AuthenticationManager.shared.signInUser(email: email, password: password)
                    secondQueue.leave()
                } catch {
                    XCTFail("Failed email authentication: \(error.localizedDescription)")
                    secondQueue.leave()
                }
            }
        }
        
        secondQueue.notify(queue: .main) {
            let db = Firestore.firestore()
            let collectionRef = db.collection("users")
            let userID = DiscoverNUSTests.testUser1
            let userRef = collectionRef.document(userID)
            
            let data: [String: Any] = [
                "id": userID,
                "level": 18,
                "exp": 500,
                "username": "hello",
                "quests": [],
                "GamesPlayed": 0,
                "GamesWon": 0
            ]
            
            userRef.setData(data) { error in
                if let error = error {
                    XCTFail("Failed to set data: \(error.localizedDescription)")
                } else {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        let expectation = XCTestExpectation(description: "deleting set up")
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        let userID = DiscoverNUSTests.testUser1
        let userRef = collectionRef.document(userID)
                
        let queue = DispatchGroup()
        queue.enter()
        userRef.delete { error in
            if let error = error {
                XCTFail("Failed to delete data: \(error.localizedDescription)")
                expectation.fulfill()
            }
            queue.leave()
        }
        
        queue.notify(queue: .main) {
            if let user = Auth.auth().currentUser {
                user.delete { error in
                    if let error = error {
                        XCTFail("Failed to delete user: \(error.localizedDescription)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testGetQuestFunction1() throws {
        let expectation = XCTestExpectation(description: "Fetch data asynchronously")
        
        QuestManager.getQuest(imageHandler: ImageHandler(), questId: "Cosmic Caffeine Quest") { result in
            XCTAssertEqual(result.name, "Cosmic Caffeine Quest", "getting quest 1 failed")
            XCTAssertEqual(result.expGained, 600, "getting quest 1 failed")
            XCTAssertEqual(result.timelimit, 300, "getting quest 1 failed")
            XCTAssertEqual(result.position.latitude, 1.295916739758068, "getting quest 1 failed")
            XCTAssertEqual(result.position.longitude, 103.78020984790747, "getting quest 1 failed")
            XCTAssertEqual(result.description, "Standing 16 floors tall and covering 30,000 m2 of floor space, the new Wet Science Building at NUS (National University of Singapore) includes state-of-the-art research and teaching wet laboratories, as well as extensive seminar and administrative spaces. Building sensors are placed within the ceiling and lighting fixtures, communicating with each other via an Internet of Things (IoT) network. They gather valuable information on everything from movement, space utilisation and temperature, providing a highly economical way for the NUS facilities team to obtain high quality data. Armed with this data, building systems such as lighting and air conditioning can be dialled up or down on a room by room basis. Now in regular use, the NUS Wet Sciences Building is serving as a world-class, sustainable environment in which scientific progress can be made!", "getting quest 1 failed")
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGetQuestFunction2() throws {
        let expectation = XCTestExpectation(description: "Fetch data asynchronously")
        
        QuestManager.getQuest(imageHandler: ImageHandler(), questId: "Auditorium 1 Exploration") { result in
            XCTAssertEqual(result.name, "Auditorium 1 Exploration", "getting quest 2 failed")
            XCTAssertEqual(result.expGained, 400, "getting quest 2 failed")
            XCTAssertEqual(result.timelimit, 600, "getting quest 2 failed")
            XCTAssertEqual(result.position.latitude, 1.303957566947427, "getting quest 2 failed")
            XCTAssertEqual(result.position.longitude, 103.77347657229048, "getting quest 2 failed")
            XCTAssertEqual(result.description, "The UTown auditorium is a popular gathering place for functions and lectures. It's also a great place to get a feel for your future. No matter what event you attend, you're sure to come away with a new perspective.", "getting quest 2 failed")
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGetQuestFunction3() throws {
        let expectation = XCTestExpectation(description: "Fetch data asynchronously")
        
        QuestManager.getQuest(imageHandler: ImageHandler(), questId: "Medicine & Science Hub") { result in
            XCTAssertEqual(result.name, "Medicine & Science Hub", "getting quest 3 failed")
            XCTAssertEqual(result.expGained, 750, "getting quest 3 failed")
            XCTAssertEqual(result.timelimit, 600, "getting quest 3 failed")
            XCTAssertEqual(result.position.latitude, 1.2970751496734374, "getting quest 3 failed")
            XCTAssertEqual(result.position.longitude, 103.78136140587036, "getting quest 3 failed")
            XCTAssertEqual(result.description, "The Medicine & Science Library was established in 2023 through the merger of the Medical Library and Science Library. The former is the oldest library in NUS. Its origin can be traced back to 1905 when the Straits and Federated Malay States Government Medical School was set up. The latter was opened on 19 May 1986. The merger brings together our strong collection on dentistry, medicine, nursing, pharmacy, biological and life sciences, chemistry, mathematics, statistics & applied probability, materials science and physics.", "getting quest 3 failed")
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGetUserDocument1() throws {
        let expectation = XCTestExpectation(description: "Fetch data asynchronously")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                XCTAssertEqual(player.id, DiscoverNUSTests.testUser1)
                XCTAssertEqual(player.level, 18)
                XCTAssertEqual(player.exp, 500)
                XCTAssertEqual(player.username, "hello")
                XCTAssertEqual(player.quests, [])
                XCTAssertEqual(player.multiplayerGamesPlayed, 0)
                XCTAssertEqual(player.multiplayerGamesWon, 0)
                expectation.fulfill()
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGetUserDocument2() throws {
        let expectation = XCTestExpectation(description: "Fetch data asynchronously")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser2)
                XCTAssertEqual(player.id, DiscoverNUSTests.testUser2)
                XCTAssertEqual(player.level, 1)
                XCTAssertEqual(player.exp, 0)
                XCTAssertEqual(player.username, "")
                XCTAssertEqual(player.quests, [])
                XCTAssertEqual(player.multiplayerGamesPlayed, 0)
                XCTAssertEqual(player.multiplayerGamesWon, 0)
                
                //cleanup
                let db = Firestore.firestore()
                let collectionRef = db.collection("users")
                let userID = DiscoverNUSTests.testUser2
                let userRef = collectionRef.document(userID)
                userRef.delete { error in
                    if let error = error {
                        XCTFail("Failed to delete data: \(error.localizedDescription)")
                    }
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testNewQuest1() throws {
        let expectation = XCTestExpectation(description: "Testing newQuest function")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                QuestManager.newQuest(count: 0, playerInfo: player) { player in
                    XCTAssertEqual(player.quests.count, 3)
                    XCTAssertNotEqual(player.quests[0], player.quests[1])
                    XCTAssertNotEqual(player.quests[1], player.quests[2])
                    XCTAssertNotEqual(player.quests[0], player.quests[2])
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testNewQuest2() throws {
        let expectation = XCTestExpectation(description: "Testing newQuest function")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                let testQuests = ["Cosmic Caffeine Quest", "Medicine & Science Hub"]
                let newPlayer = Player(id: player.id, level: player.level, username: player.username, exp: player.exp, image: player.image, quests: testQuests, multiplayerGamesPlayed: player.multiplayerGamesPlayed, multiplayerGamesWon: player.multiplayerGamesWon)
                QuestManager.newQuest(count: 2, playerInfo: newPlayer) { player in
                    XCTAssertEqual(player.quests.count, 3)
                    XCTAssertNotEqual(player.quests[0], player.quests[1])
                    XCTAssertNotEqual(player.quests[1], player.quests[2])
                    XCTAssertNotEqual(player.quests[0], player.quests[2])
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testLevelUp() throws {
        XCTAssertEqual(550, LevelSystem.expToNext(level: 1))
        XCTAssertEqual(600, LevelSystem.expToNext(level: 2))
        XCTAssertEqual(650, LevelSystem.expToNext(level: 3))
        XCTAssertEqual(1000, LevelSystem.expToNext(level: 10))
        XCTAssertEqual(5500, LevelSystem.expToNext(level: 100))
    }
    
    func testTotalExp() throws {
        XCTAssertEqual(0, LevelSystem.totalExp(level: 1, currentExp: 0))
        XCTAssertEqual(300, LevelSystem.totalExp(level: 1, currentExp: 300))
        XCTAssertEqual(2100, LevelSystem.totalExp(level: 4, currentExp: 300))
        XCTAssertEqual(6750, LevelSystem.totalExp(level: 10, currentExp: 0))
        XCTAssertEqual(7050, LevelSystem.totalExp(level: 10, currentExp: 300))
    }
    
    func testExpGain1() throws {
        let expectation = XCTestExpectation(description: "Testing exp updater function")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                
                let queue = DispatchGroup()
                queue.enter()
                LevelSystem.expGainManager(userID: player.id!, level: player.level, expGained: 300, currentExp: player.exp, questID: "", questIDArray: player.quests) {
                    error in if let error = error {
                        XCTFail("Failed to update exp: \(error.localizedDescription)")
                    }
                    queue.leave()
                }
                
                queue.notify(queue:.main) {
                    Task {
                        do {
                            let newPlayer = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                            
                            XCTAssertEqual(newPlayer.id, DiscoverNUSTests.testUser1)
                            XCTAssertEqual(newPlayer.level, 18)
                            XCTAssertEqual(newPlayer.exp, 800)
                            XCTAssertEqual(newPlayer.username, "hello")
                            XCTAssertEqual(newPlayer.quests, [])
                            XCTAssertEqual(newPlayer.multiplayerGamesPlayed, 0)
                            XCTAssertEqual(newPlayer.multiplayerGamesWon, 0)
                            expectation.fulfill()
                        } catch {
                            XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                            expectation.fulfill()
                        }
                    }
                }
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testExpGain2() throws {
        let expectation = XCTestExpectation(description: "Testing exp updater function")
        
        Task {
            do {
                let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                
                let queue = DispatchGroup()
                queue.enter()
                LevelSystem.expGainManager(userID: player.id!, level: player.level, expGained: 950, currentExp: player.exp, questID: "", questIDArray: player.quests) {
                    error in if let error = error {
                        XCTFail("Failed to update exp: \(error.localizedDescription)")
                    }
                    queue.leave()
                }
                
                queue.notify(queue:.main) {
                    Task {
                        do {
                            let newPlayer = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                            
                            XCTAssertEqual(newPlayer.id, DiscoverNUSTests.testUser1)
                            XCTAssertEqual(newPlayer.level, 19)
                            XCTAssertEqual(newPlayer.exp, 50)
                            XCTAssertEqual(newPlayer.username, "hello")
                            XCTAssertEqual(newPlayer.quests, [])
                            XCTAssertEqual(newPlayer.multiplayerGamesPlayed, 0)
                            XCTAssertEqual(newPlayer.multiplayerGamesWon, 0)
                            expectation.fulfill()
                        } catch {
                            XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                            expectation.fulfill()
                        }
                    }
                }
            } catch {
                XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testInputUsername() throws {
        let expectation = XCTestExpectation(description: "Testing username updater function")
        
        let queue = DispatchGroup()
        queue.enter()
        UsernameHandler.inputUsername(username: "hanxi", userID: DiscoverNUSTests.testUser1 ) { error in
            if let error = error {
                XCTFail("Failed to update username: \(error.localizedDescription)")
            }
            queue.leave()
        }
        
        queue.notify(queue: .main) {
            Task {
                do {
                    let player = try await AuthenticationManager.shared.getUserDocument(profile: ImageHandler(), userId: DiscoverNUSTests.testUser1)
                    XCTAssertEqual(player.username, "hanxi")
                    expectation.fulfill()
                } catch {
                    XCTFail("Failed to get existing user document: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testUpdatePassword1() throws {
        let expectation = XCTestExpectation(description: "Testing password updater function")
        
        let email = "testuser@example.com"
        let password = "testpassword"
        let newPassword = "testme123"
        
        Task{
            do {
                let queue = DispatchGroup()
                queue.enter()
                try await SettingsViewModel().updatePassword(currentPassword: password, newPassword: newPassword, confirmPassword: newPassword) { error in
                    if let error = error {
                        XCTFail("Failed updating password: \(error.localizedDescription)")
                    }
                    queue.leave()
                }
                
                queue.notify(queue: .main) {
                    Task {
                        do {
                            try AuthenticationManager.shared.signOut()
                            try await AuthenticationManager.shared.signInUser(email: email, password: newPassword)
                            expectation.fulfill()
                        } catch {
                            XCTFail("Failed updating password: \(error.localizedDescription)")
                            expectation.fulfill()
                        }
                    }
                }
            } catch {
                XCTFail("Failed updating password: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
}
