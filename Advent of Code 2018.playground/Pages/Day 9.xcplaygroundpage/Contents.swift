import Foundation

struct Player {
    let id: Int
    var scoredMarbles: [Int] = []
    
    var score: Int {
        return scoredMarbles.reduce(0, +)
    }
    
    // This is required due to the properties being a mix of default and non-default
    init(id: Int) {
        self.id = id
    }
}

enum PlayerError: Swift.Error {
    case noPlayers
}

func highestScore(playerCount: Int, marbleCount: Int) throws -> Int {
    var marbleBag = [Int](0...marbleCount)
    var marbleArray = [marbleBag.remove(at: 0)]
    var currentMarbleIndex = 0
    /// Note that this is 1 indexed, not 0 indexed
    var currentPlayer = 1
    
    let seedArray = [Int](1...playerCount)
    var players = seedArray.map { Player(id: $0) }
    
    while let marble = marbleBag.first {
        let thisMarble = marbleBag.remove(at: 0)
        if thisMarble % 23 == 0 {
            players[currentPlayer - 1].scoredMarbles += [thisMarble]
            
            let indexToRemove: Int = {
                var newIndex = currentMarbleIndex
                for i in 1...7 {
                    newIndex -= 1
                    if newIndex < 0 {
                        newIndex = marbleArray.count - 1
                    }
                }
                return newIndex
            }()
            
            let winningMarble = marbleArray.remove(at: indexToRemove + 1)
            players[currentPlayer - 1].scoredMarbles += [winningMarble]
            
            let newMarbleIndex: Int = {
                var newIndex = indexToRemove + 1
                if newIndex >= marbleArray.count {
                    newIndex = 0
                }
                return newIndex
            }()
            
            currentMarbleIndex = newMarbleIndex - 1
        } else {
            let newMarbleIndex: Int = {
                var oldIndex = currentMarbleIndex
                for i in 1...2 {
                    oldIndex += 1
                    if oldIndex >= marbleArray.count {
                        oldIndex = 0
                    }
                }
                return oldIndex
            }()
            
            marbleArray.insert(thisMarble, at: newMarbleIndex + 1)
            currentMarbleIndex = newMarbleIndex
        }
        
        currentPlayer += 1
        if currentPlayer > players.count {
            currentPlayer = 1
        }
        
//        print(marbleArray) // This confirms that each stage matches the example
    }
    
    let playersByScore = players.sorted { $0.score > $1.score }
    
    guard let highestScoringPlayer = playersByScore.first else { throw PlayerError.noPlayers }
    
    print(highestScoringPlayer)
    print(highestScoringPlayer.score)
    
    return highestScoringPlayer.score
    
}

do {
//    let example0 = try highestScore(playerCount: 9, marbleCount: 25) // Correctly returning 32
//    let example1 = try highestScore(playerCount: 10, marbleCount: 1618) // Correctly returning 8317
//    let example2 = try highestScore(playerCount: 13, marbleCount: 7999) // Correctly returning 146373 (Player(id: 12, scoredMarbles: [207, 37, 506, 95, 805, 343, 1104, 475, 1403, 606, 1702, 737, 2001, 374, 2300, 988, 2599, 1121, 2898, 1252, 3197, 1383, 3496, 653, 3795, 130, 4094, 766, 4393, 1898, 4692, 2029, 4991, 932, 5290, 990, 5589, 450, 5888, 2544, 6187, 2675, 6486, 2802, 6785, 1269, 7084, 1323, 7383, 3190, 7682, 3321, 7981, 3452]))
//    let example3 = try highestScore(playerCount: 17, marbleCount: 1104) // Correctly returning 2764 (Player(id: 16, scoredMarbles: [322, 140, 713, 10, 1104, 475]))
//    let example4 = try highestScore(playerCount: 21, marbleCount: 6111) // Correctly returning 54718 (Player(id: 5, scoredMarbles: [299, 55, 782, 336, 1265, 101, 1748, 753, 2231, 962, 2714, 1170, 3197, 1383, 3680, 685, 4163, 1800, 4646, 866, 5129, 2217, 5612, 195, 6095, 2634]))
//    let example5 = try highestScore(playerCount: 30, marbleCount: 5807) // Correctly returning 37305 (Player(id: 20, scoredMarbles: [230, 99, 920, 74, 1610, 696, 2300, 988, 2990, 1293, 3680, 685, 4370, 1890, 5060, 2183, 5750, 2487]))
//    let part1 = try highestScore(playerCount: 416, marbleCount: 71617) // Going to take too long, going to copy over to main.swift
} catch {
    print(error)
}


