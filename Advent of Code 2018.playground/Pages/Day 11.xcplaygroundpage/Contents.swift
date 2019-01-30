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
}

/*
FuelCell(position: CGPoint(x: 3, y: 5), serialNumber: 8).powerLevel         //  4 (correct)
FuelCell(position: CGPoint(x: 122, y: 79), serialNumber: 57).powerLevel     // -5 (correct)
FuelCell(position: CGPoint(x: 217, y: 196), serialNumber: 39).powerLevel    //  0 (correct)
FuelCell(position: CGPoint(x: 101, y: 153), serialNumber: 71).powerLevel    //  4 (correct)
*/

//let exampleGrid = FuelCell.grid(serialNumber: 18)
//let exampleArray = [exampleGrid[33][45].powerLevel, exampleGrid[45][33].powerLevel, exampleGrid[45 - 1][33 - 1].powerLevel, exampleGrid[45 - 2][33 - 2].powerLevel]

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
