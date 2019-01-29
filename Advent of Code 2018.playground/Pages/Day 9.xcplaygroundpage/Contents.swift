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



var marbleBag = [Int](1...25)
var marbleArray = [0]
var currentMarbleIndex = 0
/// Note that this is 1 indexed, not 0 indexed
var currentPlayer = 1

let seedArray = [Int](1...9)
var players = seedArray.map { Player(id: $0/*, marbleCount: 25, playerCount: seedArray.count*/) }
//players.forEach { print($0) }

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
    
    print(marbleArray) // This confirms that each stage matches the example
}

let playersByScore = players.sorted { $0.score > $1.score }
if let highestScoringPlayer = playersByScore.first {
    print(highestScoringPlayer)
    print(highestScoringPlayer.score)
}


