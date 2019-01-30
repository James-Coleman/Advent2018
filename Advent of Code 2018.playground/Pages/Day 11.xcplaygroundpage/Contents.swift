import Foundation
import CoreGraphics

extension Int {
    var hundredthDigit: Int {
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
    
    var rackID: Int {
        return Int(position.x + 10)
    }
    
    var powerLevel: Int {
        var level = rackID
        level *= Int(position.y)
        level += serialNumber
        level *= rackID
        let hundredsDigit = level.hundredthDigit
        return hundredsDigit - 5
    }
}

FuelCell(position: CGPoint(x: 3, y: 5), serialNumber: 8).powerLevel         //  4 (correct)
FuelCell(position: CGPoint(x: 122, y: 79), serialNumber: 57).powerLevel     // -5 (correct)
FuelCell(position: CGPoint(x: 217, y: 196), serialNumber: 39).powerLevel    //  0 (correct)
FuelCell(position: CGPoint(x: 101, y: 153), serialNumber: 71).powerLevel    //  4 (correct)
