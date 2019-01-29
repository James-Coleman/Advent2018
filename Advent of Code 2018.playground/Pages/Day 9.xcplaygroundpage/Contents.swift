import Foundation

struct Player {
    let id: Int
//    var marbles: [Int]
    var scoredMarbles: [Int] = []
    
    var score: Int {
        return scoredMarbles.reduce(0, +)
    }
    
    // This is required due to the properties being a mix of default and non-default
    init(id: Int) {
        self.id = id
    }
    
    /*
    init(id: Int, marbleCount: Int, playerCount: Int) {
        self.id = id
        self.marbles = stride(from: id, through: marbleCount, by: playerCount).map { $0 }
    }
    */
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
    let example0 = try highestScore(playerCount: 9, marbleCount: 25)
    let example1 = try highestScore(playerCount: 10, marbleCount: 1618) // Correctly returning 8317
} catch {
    print(error)
}


