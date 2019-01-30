import Foundation
import CoreGraphics

extension Int {
    var hundredsDigit: Int {
        if -99...99 ~= self {
            return 0
        } else {
            let string = String(self)
            let hundredsOnly = string.suffix(3)
            let hundredsDigit = hundredsOnly.first!
            return Int(String(hundredsDigit))!
        }
    }
}

struct FuelCell {
    let position: CGPoint
    let serialNumber: Int
    
    private var rackID: Int {
        return Int(position.x + 10)
    }
    
    public var powerLevel: Int {
        var level = rackID
        level *= Int(position.y)
        level += serialNumber
        level *= rackID
        let hundredsDigit = level.hundredsDigit
        return hundredsDigit - 5
    }
    
    enum FuelCellError: Swift.Error {
        case arrayTooShort(arrayLength: Int, expected: Int)
    }
    
    public static func grid(serialNumber: Int) -> [[FuelCell]] {
        return (1...300).map { y -> [FuelCell] in
            return (1...300).map { x -> FuelCell in
                return FuelCell(position: CGPoint(x: x, y: y), serialNumber: serialNumber)
            }
        }
    }
    
    public static func grid3x3(xCorner: Int, yCorner: Int, serialNumber: Int) -> [[FuelCell]] {
        return (yCorner..<yCorner + 3).map { y -> [FuelCell] in
            return (xCorner..<xCorner + 3).map { x -> FuelCell in
                return FuelCell(position: CGPoint(x: x, y: y), serialNumber: serialNumber)
            }
        }
    }
    
    public static func fuelCellAt(x: Int, y: Int, in array: [[FuelCell]]) throws -> FuelCell {
        guard array.count >= y else { throw FuelCellError.arrayTooShort(arrayLength: array.count, expected: y) }
        let subArray = array[y - 1]
        guard subArray.count >= x else { throw FuelCellError.arrayTooShort(arrayLength: subArray.count, expected: x) }
        return subArray[x - 1]
    }
    
    public static func grid3x3(x: Int, y: Int, source: [[FuelCell]]) throws -> [[FuelCell]] {
        // Calculate the required count offset
//        let countOffset = 
        guard (source.count - 2) >= y else { throw FuelCellError.arrayTooShort(arrayLength: source.count, expected: y) }
        
        let subArray1 = source[y - 1]
        let subArray2 = source[y]
        let subArray3 = source[y + 1]
        
        guard (subArray1.count - 2) >= x else { throw FuelCellError.arrayTooShort(arrayLength: subArray1.count, expected: x) }
        guard (subArray2.count - 2) >= x else { throw FuelCellError.arrayTooShort(arrayLength: subArray2.count, expected: x) }
        guard (subArray3.count - 2) >= x else { throw FuelCellError.arrayTooShort(arrayLength: subArray3.count, expected: x) }
        
        return [
            // Replace these with slices
            [subArray1[x - 1], subArray1[x], subArray1[x + 1]],
            [subArray2[x - 1], subArray2[x], subArray2[x + 1]],
            [subArray3[x - 1], subArray3[x], subArray3[x + 1]]
        ]
    }
}

struct FuelCellSquare {
    let fuelCells: [[FuelCell]]
    
    var totalPower: Int {
        let combinedArray = fuelCells.reduce([], +)
        let power = combinedArray.map { $0.powerLevel }
        return power.reduce(0, +)
    }
}

/*
FuelCell(position: CGPoint(x: 3, y: 5), serialNumber: 8).powerLevel         //  4 (correct)
FuelCell(position: CGPoint(x: 122, y: 79), serialNumber: 57).powerLevel     // -5 (correct)
FuelCell(position: CGPoint(x: 217, y: 196), serialNumber: 39).powerLevel    //  0 (correct)
FuelCell(position: CGPoint(x: 101, y: 153), serialNumber: 71).powerLevel    //  4 (correct)
*/

do {
    let exampleGrid = FuelCell.grid(serialNumber: 18)
    let exampleSquare = try FuelCell.grid3x3(x: 33, y: 45, source: exampleGrid)
    /*
    exampleSquare.forEach { array in
        let powerLevels = array.map { $0.powerLevel }
        print(powerLevels)
    }
    */
    let fuelCellSquare = FuelCellSquare(fuelCells: exampleSquare)
    fuelCellSquare.totalPower // 29 (correct)
    
//    let exampleGrid2 = FuelCell.grid(serialNumber: 42)
//    let exampleSquare2 = try FuelCell.grid3x3(x: 21, y: 61, source: exampleGrid2)
//    let fuelCellSquare2 = FuelCellSquare(fuelCells: exampleSquare2)
//    fuelCellSquare2.totalPower // 30 (correct)
} catch {
    print(error)
}

//let exampleArray = [exampleGrid[33][45].powerLevel, exampleGrid[45][33].powerLevel, exampleGrid[45 - 1][33 - 1].powerLevel, exampleGrid[45 - 2][33 - 2].powerLevel]

/*
let example3x3 = FuelCell.grid3x3(xCorner: 33, yCorner: 45, serialNumber: 18)
example3x3.forEach { array in
    let powerLevels = array.map { $0.powerLevel }
    print(powerLevels)
}

do {
    try FuelCell.fuelCellAt(x: 1, y: 1, in: example3x3).powerLevel
    try FuelCell.fuelCellAt(x: 1, y: 2, in: example3x3).powerLevel
    try FuelCell.fuelCellAt(x: 1, y: 3, in: example3x3).powerLevel
//    try FuelCell.fuelCellAt(x: 1, y: 4, in: example3x3).powerLevel // designed to fail (arrayTooShort(arrayLength: 3, expected: 4))
} catch {
    print(error)
}
*/

// This takes too long to run in the playground but works in 5 seconds in main.swift
/*
do {
    var highestTotalSquare: FuelCellSquare? = nil
    
    let challengeGrid = FuelCell.grid(serialNumber: 4842)
    
    for y in 1...298 {
        for x in 1...298 {
            let newGrid = try FuelCell.grid3x3(x: x, y: y, source: challengeGrid)
            let newSquare = FuelCellSquare(fuelCells: newGrid)
            let currentHighestTotal = highestTotalSquare?.totalPower ?? 0
            if newSquare.totalPower > currentHighestTotal {
                highestTotalSquare = newSquare
            }
        }
    }
    
 print(highestTotalSquare) // Part 1 answer: 20,83
} catch {
    print(error)
}
*/


