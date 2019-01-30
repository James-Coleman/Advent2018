import Foundation
import CoreGraphics

struct Point {
    let position: CGPoint
    let velocity: CGPoint
    
    enum PointError: Swift.Error {
        case wrongInitStringCount(actualCount: Int)
        case isNotInt(string: String)
        case emptyArray
    }
    
    init(position: CGPoint, velocity: CGPoint) {
        self.position = position
        self.velocity = velocity
    }
    
    init(string: String) throws {
        let splitString = string.split { (character) -> Bool in
            if character == "<" {
                return true
            } else if character == " " {
                return true
            } else if character == "," {
                return true
            } else if character == ">" {
                return true
            } else {
                return false
            }
        }
        
        let splitStringCount = splitString.count
        guard splitStringCount == 6 else { throw PointError.wrongInitStringCount(actualCount: splitStringCount) }
        
        let array = [splitString[1], splitString[2], splitString[4], splitString[5]]
        let intArray = try array.map { substring -> Int in
            guard let int = Int(substring) else { throw PointError.isNotInt(string: String(substring)) }
            return int
        }
        
        self.position = CGPoint(x: intArray[0], y: intArray[1])
        self.velocity = CGPoint(x: intArray[2], y: intArray[3])
    }
    
    var asInputString: String {
        let positionXInt = Int(position.x)
        let positionYInt = Int(position.y)
        let velocityXInt = Int(velocity.x)
        let velocityYInt = Int(velocity.y)
        
        return "position=<\(positionXInt),\(positionYInt)> velocity=<\(velocityXInt),\(velocityYInt)>"
    }
    
    public static func pointArray(from: String) throws -> [Point] {
        let splitArray = from.split(separator: "\n")
        let pointArray = try splitArray.map { try Point(string: String($0)) }
        return pointArray
    }
    
    public static func gridSize(from points: [Point]) throws -> CGRect {
        let sortedByX = points.sorted { $0.position.x < $1.position.x }
        let sortedByY = points.sorted { $0.position.y < $1.position.y }
        
        guard
            let firstX = sortedByX.first,
            let lastX = sortedByX.last,
            let firstY = sortedByY.first,
            let lastY = sortedByY.last
            else { throw PointError.emptyArray }
        
        let floatX = firstX.position.x
        let x = Int(floatX)
        
        let floatY = firstY.position.y
        let y = Int(floatY)
        
        let floatWidth = lastX.position.x - firstX.position.x
        let width = Int(floatWidth)
        
        let floatHeight = lastY.position.y - firstY.position.y
        let height = Int(floatHeight)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    public static func grid(from points: [Point], pointCharacter: Character = "#", blankCharacter: Character = ".") throws -> String {
        let rect = try Point.gridSize(from: points)
        
        let minX = Int(rect.minX)
        let maxX = Int(rect.maxX)
        let minY = Int(rect.minY)
        let maxY = Int(rect.maxY)
        
        var stringToReturn = ""
        
        for y in minY...maxY {
            for x in minX...maxX {
                let cgX = CGFloat(x)
                let cgY = CGFloat(y)
                
                if points.contains(where: { (point) -> Bool in
                    return point.position.x == cgX && point.position.y == cgY
                }) {
                    stringToReturn.append(pointCharacter)
                } else {
                    stringToReturn.append(blankCharacter)
                }
                
                if x == maxX {
                    stringToReturn += "\n"
                }
            }
        }
        
        return stringToReturn
    }
    
    public static func grid(from string: String) throws -> String {
        let points = try Point.pointArray(from: string)
        return try Point.grid(from: points)
    }
    
    public static func nextGeneration(from points: [Point]) -> [Point] {
        return points.map { (point) -> Point in
            let newXPosition = point.position.x + point.velocity.x
            let newYPosition = point.position.y + point.velocity.y
            let newPosition = CGPoint(x: newXPosition, y: newYPosition)
            return Point(position: newPosition, velocity: point.velocity)
        }
    }
    
    public static func previousGeneration(from points: [Point]) -> [Point] {
        return points.map { (point) -> Point in
            let newXPosition = point.position.x - point.velocity.x
            let newYPosition = point.position.y - point.velocity.y
            let newPosition = CGPoint(x: newXPosition, y: newYPosition)
            return Point(position: newPosition, velocity: point.velocity)
        }
    }
}

// This confirms that the Point is being created correctly from a single string input
/*
do {
    let point = try Point(string: "position=<-3, 11> velocity=< 1, -2>")
    print(point)
} catch {
    print(error)
}
*/

let exampleInput = """
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
"""

// This confirms that an array of Points can be successfully made from an input string
/*
do {
    let exampleArray = try Point.pointArray(from: exampleInput)
    exampleArray.forEach { print($0) }
} catch {
    print(error)
}
*/

// This confirms that the grid is being calculated correctly
/*
do {
    let grid = try Point.grid(from: exampleInput)
    print(grid)
} catch {
    print(error)
}
*/

// This confirms the example is working correctly.
/*
do {
    var points = try Point.pointArray(from: exampleInput)
    for _ in 0...4 {
        print(try Point.grid(from: points))
        points = Point.nextGeneration(from: points)
    }
} catch {
    print(error)
}
*/

// This shows that the grid can be drawn with custom characters.
// Many characters are not actually monospaced, this is an example of one that is.
/*
do {
    var points = try Point.pointArray(from: exampleInput)
    for _ in 0...4 {
        print(try Point.grid(from: points, pointCharacter: "●", blankCharacter: " "))
        points = Point.nextGeneration(from: points)
    }
} catch {
    print(error)
}
*/

let part1Input = """
position=< 53777,  21594> velocity=<-5, -2>
position=< 53761,  53776> velocity=<-5, -5>
position=<-32066,  53779> velocity=< 3, -5>
position=<-21287,  43043> velocity=< 2, -4>
position=< 10848, -42773> velocity=<-1,  4>
position=<-10596,  53770> velocity=< 1, -5>
position=<-42798,  53772> velocity=< 4, -5>
position=<-21308, -32037> velocity=< 2,  3>
position=<-21332,  10863> velocity=< 2, -1>
position=<-10596, -21313> velocity=< 1,  2>
position=<-42750, -53498> velocity=< 4,  5>
position=<-10569, -21315> velocity=< 1,  2>
position=<-21334,  53779> velocity=< 2, -5>
position=< 43055, -10586> velocity=<-4,  1>
position=< 21588, -21313> velocity=<-2,  2>
position=< 53795,  32316> velocity=<-5, -3>
position=< 43061, -21319> velocity=<-4,  2>
position=<-10590, -21317> velocity=< 1,  2>
position=<-21344, -32042> velocity=< 2,  3>
position=<-53491, -42769> velocity=< 5,  4>
position=< 53801,  21595> velocity=<-5, -2>
position=< 43055, -42771> velocity=<-4,  4>
position=<-32027, -21319> velocity=< 3,  2>
position=< 43068,  21598> velocity=<-4, -2>
position=< 32307, -53499> velocity=<-3,  5>
position=< 53787, -53491> velocity=<-5,  5>
position=<-21288,  53778> velocity=< 2, -5>
position=<-42787,  10862> velocity=< 4, -1>
position=<-53522,  32325> velocity=< 5, -3>
position=<-53513,  21595> velocity=< 5, -2>
position=<-42741, -32042> velocity=< 4,  3>
position=< 43022, -53495> velocity=<-4,  5>
position=< 43076,  21593> velocity=<-4, -2>
position=< 53757, -10589> velocity=<-5,  1>
position=<-32035,  43047> velocity=< 3, -4>
position=< 32328, -42768> velocity=<-3,  4>
position=< 21608, -53500> velocity=<-2,  5>
position=< 53790, -21318> velocity=<-5,  2>
position=<-10561, -32038> velocity=< 1,  3>
position=<-32068, -42768> velocity=< 3,  4>
position=< 10861, -10587> velocity=<-1,  1>
position=< 43068,  53779> velocity=<-4, -5>
position=< 21568, -10592> velocity=<-2,  1>
position=<-42766, -10584> velocity=< 4,  1>
position=<-53469, -10585> velocity=< 5,  1>
position=< 21564,  32322> velocity=<-2, -3>
position=<-42762, -32037> velocity=< 4,  3>
position=< 21576, -10587> velocity=<-2,  1>
position=<-10567,  53774> velocity=< 1, -5>
position=<-21283,  21589> velocity=< 2, -2>
position=<-32022, -32042> velocity=< 3,  3>
position=<-21309,  10871> velocity=< 2, -1>
position=< 53778,  53774> velocity=<-5, -5>
position=<-53493, -21317> velocity=< 5,  2>
position=< 43023, -42766> velocity=<-4,  4>
position=< 43030, -42768> velocity=<-4,  4>
position=< 10853,  21597> velocity=<-1, -2>
position=< 21584,  53778> velocity=<-2, -5>
position=<-53492,  53770> velocity=< 5, -5>
position=<-21309, -10592> velocity=< 2,  1>
position=<-10573, -53497> velocity=< 1,  5>
position=<-53513, -10592> velocity=< 5,  1>
position=<-42750, -42768> velocity=< 4,  4>
position=< 21589,  32321> velocity=<-2, -3>
position=< 43042,  21594> velocity=<-4, -2>
position=< 32308, -10590> velocity=<-3,  1>
position=<-32055, -21315> velocity=< 3,  2>
position=<-21318, -42767> velocity=< 2,  4>
position=<-53501,  10864> velocity=< 5, -1>
position=<-53474, -53496> velocity=< 5,  5>
position=<-53513, -21318> velocity=< 5,  2>
position=<-10617, -21318> velocity=< 1,  2>
position=< 10869, -42770> velocity=<-1,  4>
position=< 43034, -21318> velocity=<-4,  2>
position=< 53785,  21597> velocity=<-5, -2>
position=<-32070, -53491> velocity=< 3,  5>
position=<-42771, -32039> velocity=< 4,  3>
position=<-42786, -32045> velocity=< 4,  3>
position=<-10597,  53777> velocity=< 1, -5>
position=<-32023, -32042> velocity=< 3,  3>
position=< 53787, -10592> velocity=<-5,  1>
position=<-21318,  53776> velocity=< 2, -5>
position=<-10585, -53499> velocity=< 1,  5>
position=< 32315,  32323> velocity=<-3, -3>
position=< 53794, -53496> velocity=<-5,  5>
position=< 10864, -42766> velocity=<-1,  4>
position=<-32055, -42770> velocity=< 3,  4>
position=<-53467,  53770> velocity=< 5, -5>
position=< 32295,  53770> velocity=<-3, -5>
position=< 32291, -32038> velocity=<-3,  3>
position=<-32053,  21593> velocity=< 3, -2>
position=< 10888,  43047> velocity=<-1, -4>
position=< 53777,  53776> velocity=<-5, -5>
position=< 43070,  43052> velocity=<-4, -4>
position=<-53509,  53775> velocity=< 5, -5>
position=< 43047, -21310> velocity=<-4,  2>
position=< 10896,  53774> velocity=<-1, -5>
position=< 10861,  32320> velocity=<-1, -3>
position=< 21601,  43050> velocity=<-2, -4>
position=< 53749, -21314> velocity=<-5,  2>
position=<-10566,  43043> velocity=< 1, -4>
position=< 53747, -32037> velocity=<-5,  3>
position=< 21593, -42773> velocity=<-2,  4>
position=<-42782,  21598> velocity=< 4, -2>
position=<-21299, -10592> velocity=< 2,  1>
position=<-42766, -10592> velocity=< 4,  1>
position=< 43022, -21311> velocity=<-4,  2>
position=< 53801, -21314> velocity=<-5,  2>
position=<-42742,  53779> velocity=< 4, -5>
position=< 43042,  10862> velocity=<-4, -1>
position=<-32066,  32322> velocity=< 3, -3>
position=< 53746,  10871> velocity=<-5, -1>
position=< 43038,  43050> velocity=<-4, -4>
position=< 32349, -10588> velocity=<-3,  1>
position=< 10858,  53778> velocity=<-1, -5>
position=< 32304, -42773> velocity=<-3,  4>
position=< 43042, -53499> velocity=<-4,  5>
position=< 43035,  10864> velocity=<-4, -1>
position=<-32021,  21593> velocity=< 3, -2>
position=<-53501, -53494> velocity=< 5,  5>
position=< 43074,  32325> velocity=<-4, -3>
position=< 21620, -53499> velocity=<-2,  5>
position=<-21320,  32322> velocity=< 2, -3>
position=< 43050,  53779> velocity=<-4, -5>
position=<-10601, -32045> velocity=< 1,  3>
position=< 21608, -21310> velocity=<-2,  2>
position=<-42794, -10592> velocity=< 4,  1>
position=< 53750,  10863> velocity=<-5, -1>
position=<-21341, -53500> velocity=< 2,  5>
position=< 32348,  10871> velocity=<-3, -1>
position=< 32307, -21316> velocity=<-3,  2>
position=<-32019, -32042> velocity=< 3,  3>
position=< 53774, -32046> velocity=<-5,  3>
position=<-21286, -42764> velocity=< 2,  4>
position=<-10615,  21598> velocity=< 1, -2>
position=< 21604,  32316> velocity=<-2, -3>
position=< 32312, -53491> velocity=<-3,  5>
position=<-21339, -42764> velocity=< 2,  4>
position=<-42766,  43047> velocity=< 4, -4>
position=< 10888, -32037> velocity=<-1,  3>
position=< 53754,  21598> velocity=<-5, -2>
position=< 21576,  32320> velocity=<-2, -3>
position=< 21580, -21317> velocity=<-2,  2>
position=< 53750, -32041> velocity=<-5,  3>
position=<-21323, -53495> velocity=< 2,  5>
position=< 43066,  21592> velocity=<-4, -2>
position=< 10840, -32046> velocity=<-1,  3>
position=< 32343,  53774> velocity=<-3, -5>
position=<-10564,  53779> velocity=< 1, -5>
position=< 21590, -32043> velocity=<-2,  3>
position=< 21612,  43046> velocity=<-2, -4>
position=< 21576, -21312> velocity=<-2,  2>
position=< 53777, -32044> velocity=<-5,  3>
position=<-53493,  10863> velocity=< 5, -1>
position=< 32332,  10871> velocity=<-3, -1>
position=< 10880,  53774> velocity=<-1, -5>
position=<-53482,  32320> velocity=< 5, -3>
position=< 10889,  10862> velocity=<-1, -1>
position=<-10558, -32037> velocity=< 1,  3>
position=<-21304,  10870> velocity=< 2, -1>
position=<-32034,  21590> velocity=< 3, -2>
position=<-32039, -42770> velocity=< 3,  4>
position=< 53770,  53775> velocity=<-5, -5>
position=< 32332,  21595> velocity=<-3, -2>
position=< 32349,  53770> velocity=<-3, -5>
position=< 10886, -53496> velocity=<-1,  5>
position=<-32070,  21589> velocity=< 3, -2>
position=< 21606,  10871> velocity=<-2, -1>
position=<-42750, -53492> velocity=< 4,  5>
position=< 53772,  10869> velocity=<-5, -1>
position=<-42753,  43045> velocity=< 4, -4>
position=<-21316, -53499> velocity=< 2,  5>
position=<-32066, -53492> velocity=< 3,  5>
position=<-53509,  32319> velocity=< 5, -3>
position=<-42774, -42764> velocity=< 4,  4>
position=< 32318, -42771> velocity=<-3,  4>
position=<-21302,  53775> velocity=< 2, -5>
position=< 32349, -42764> velocity=<-3,  4>
position=< 10893, -32039> velocity=<-1,  3>
position=< 43022,  21597> velocity=<-4, -2>
position=< 43062, -10583> velocity=<-4,  1>
position=<-32066,  10870> velocity=< 3, -1>
position=< 10848, -42764> velocity=<-1,  4>
position=< 32325,  10866> velocity=<-3, -1>
position=<-53514,  53779> velocity=< 5, -5>
position=<-21317,  21591> velocity=< 2, -2>
position=<-53476, -32037> velocity=< 5,  3>
position=<-10617,  43046> velocity=< 1, -4>
position=<-42795,  53779> velocity=< 4, -5>
position=< 53758, -10592> velocity=<-5,  1>
position=<-10615, -53500> velocity=< 1,  5>
position=< 21620,  10867> velocity=<-2, -1>
position=< 10874, -42771> velocity=<-1,  4>
position=< 32315,  53778> velocity=<-3, -5>
position=<-53490, -32042> velocity=< 5,  3>
position=< 21596,  10869> velocity=<-2, -1>
position=<-32027, -10589> velocity=< 3,  1>
position=< 53782,  53778> velocity=<-5, -5>
position=<-53469,  10862> velocity=< 5, -1>
position=<-32068,  43052> velocity=< 3, -4>
position=< 32339, -53500> velocity=<-3,  5>
position=< 21624, -42764> velocity=<-2,  4>
position=< 43039,  53771> velocity=<-4, -5>
position=< 32307, -32046> velocity=<-3,  3>
position=<-53469,  10864> velocity=< 5, -1>
position=< 32323, -53491> velocity=<-3,  5>
position=< 32324, -10592> velocity=<-3,  1>
position=< 21584,  21596> velocity=<-2, -2>
position=<-42741,  32320> velocity=< 4, -3>
position=<-32066,  32317> velocity=< 3, -3>
position=< 10849,  32323> velocity=<-1, -3>
position=< 53778, -21310> velocity=<-5,  2>
position=<-10569,  10868> velocity=< 1, -1>
position=< 21607, -42764> velocity=<-2,  4>
position=< 32325, -53500> velocity=<-3,  5>
position=<-42742, -42770> velocity=< 4,  4>
position=< 21614,  21598> velocity=<-2, -2>
position=< 21596,  53771> velocity=<-2, -5>
position=< 10849, -10592> velocity=<-1,  1>
position=<-32039,  53775> velocity=< 3, -5>
position=< 43047, -21319> velocity=<-4,  2>
position=<-10583,  53779> velocity=< 1, -5>
position=<-21332,  43046> velocity=< 2, -4>
position=< 21566,  43052> velocity=<-2, -4>
position=< 53785, -21310> velocity=<-5,  2>
position=< 32303, -21319> velocity=<-3,  2>
position=< 43070, -21310> velocity=<-4,  2>
position=< 43062,  21589> velocity=<-4, -2>
position=<-53469, -42773> velocity=< 5,  4>
position=< 43070,  43052> velocity=<-4, -4>
position=<-42794,  43048> velocity=< 4, -4>
position=<-10582,  32316> velocity=< 1, -3>
position=< 21585,  32320> velocity=<-2, -3>
position=< 21585, -10591> velocity=<-2,  1>
position=< 32312,  32322> velocity=<-3, -3>
position=< 43036, -53497> velocity=<-4,  5>
position=<-42770,  43044> velocity=< 4, -4>
position=<-10569, -42772> velocity=< 1,  4>
position=< 21621, -53500> velocity=<-2,  5>
position=< 53777,  32322> velocity=<-5, -3>
position=<-10591,  43049> velocity=< 1, -4>
position=< 43037, -42768> velocity=<-4,  4>
position=<-53505, -53492> velocity=< 5,  5>
position=< 32296, -53495> velocity=<-3,  5>
position=< 21585, -53493> velocity=<-2,  5>
position=< 21600, -42769> velocity=<-2,  4>
position=< 53797, -53496> velocity=<-5,  5>
position=< 10885,  10865> velocity=<-1, -1>
position=<-42766, -21314> velocity=< 4,  2>
position=< 32304,  53770> velocity=<-3, -5>
position=< 21564, -53497> velocity=<-2,  5>
position=< 21621,  32325> velocity=<-2, -3>
position=< 10838,  53770> velocity=<-1, -5>
position=< 21598,  43052> velocity=<-2, -4>
position=< 53785, -32037> velocity=<-5,  3>
position=< 53806,  10871> velocity=<-5, -1>
position=<-21285, -21315> velocity=< 2,  2>
position=<-42761,  10870> velocity=< 4, -1>
position=<-42748, -42773> velocity=< 4,  4>
position=< 21600, -32046> velocity=<-2,  3>
position=<-32063,  21596> velocity=< 3, -2>
position=<-42782, -21317> velocity=< 4,  2>
position=< 32323,  53779> velocity=<-3, -5>
position=<-21328,  10866> velocity=< 2, -1>
position=< 43076, -53491> velocity=<-4,  5>
position=<-53477, -32040> velocity=< 5,  3>
position=<-32055, -21312> velocity=< 3,  2>
position=< 53805,  32316> velocity=<-5, -3>
position=<-32038,  21593> velocity=< 3, -2>
position=<-42761, -42770> velocity=< 4,  4>
position=<-21303,  53770> velocity=< 2, -5>
position=< 53766, -42771> velocity=<-5,  4>
position=<-32066, -21318> velocity=< 3,  2>
position=<-21320, -53497> velocity=< 2,  5>
position=< 43039, -53497> velocity=<-4,  5>
position=<-10616, -42764> velocity=< 1,  4>
position=<-53477, -10585> velocity=< 5,  1>
position=<-32012,  32316> velocity=< 3, -3>
position=<-32047, -53500> velocity=< 3,  5>
position=<-32023,  32321> velocity=< 3, -3>
position=<-32059, -21311> velocity=< 3,  2>
position=< 21620,  53773> velocity=<-2, -5>
position=<-10589,  53778> velocity=< 1, -5>
position=< 10837,  32323> velocity=<-1, -3>
position=<-53505, -53492> velocity=< 5,  5>
position=<-53525,  10864> velocity=< 5, -1>
position=<-32047,  32323> velocity=< 3, -3>
position=< 21575, -53491> velocity=<-2,  5>
position=<-42738,  53774> velocity=< 4, -5>
position=<-32015, -21315> velocity=< 3,  2>
position=< 32307, -42771> velocity=<-3,  4>
position=< 43042,  10862> velocity=<-4, -1>
position=<-10580, -42767> velocity=< 1,  4>
position=< 10877,  43050> velocity=<-1, -4>
position=<-32052, -10586> velocity=< 3,  1>
position=< 10856,  21594> velocity=<-1, -2>
position=<-10572,  10864> velocity=< 1, -1>
position=< 10849,  21591> velocity=<-1, -2>
position=<-32045, -21316> velocity=< 3,  2>
position=<-53477,  43052> velocity=< 5, -4>
position=< 43055, -53494> velocity=<-4,  5>
position=< 10869, -53496> velocity=<-1,  5>
position=< 10865,  43051> velocity=<-1, -4>
position=< 10886, -10583> velocity=<-1,  1>
position=< 21585, -10588> velocity=<-2,  1>
position=<-42758, -42766> velocity=< 4,  4>
position=< 21607, -53491> velocity=<-2,  5>
position=<-32012,  53779> velocity=< 3, -5>
position=< 53782, -42768> velocity=<-5,  4>
position=< 10837,  43044> velocity=<-1, -4>
position=<-32066, -32038> velocity=< 3,  3>
position=<-53483,  10871> velocity=< 5, -1>
position=<-21299,  53779> velocity=< 2, -5>
position=< 53794,  53770> velocity=<-5, -5>
position=< 32316, -21315> velocity=<-3,  2>
position=< 32303,  10867> velocity=<-3, -1>
position=< 43068,  53774> velocity=<-4, -5>
position=< 32315, -53493> velocity=<-3,  5>
position=< 53782, -53497> velocity=<-5,  5>
position=< 32307,  32323> velocity=<-3, -3>
position=<-10617, -10590> velocity=< 1,  1>
position=<-21335,  10871> velocity=< 2, -1>
position=<-21336, -21311> velocity=< 2,  2>
position=< 43052,  43043> velocity=<-4, -4>
position=< 32327, -32042> velocity=<-3,  3>
position=< 43062, -53497> velocity=<-4,  5>
position=< 32294, -10592> velocity=<-3,  1>
position=< 10853,  53779> velocity=<-1, -5>
position=< 32339,  10866> velocity=<-3, -1>
position=<-53477, -21319> velocity=< 5,  2>
position=<-42765,  53774> velocity=< 4, -5>
position=<-53485,  32324> velocity=< 5, -3>
position=<-53469,  21589> velocity=< 5, -2>
position=<-32071, -32043> velocity=< 3,  3>
position=< 10881, -42764> velocity=<-1,  4>
position=<-21344,  10866> velocity=< 2, -1>
position=<-10564,  32316> velocity=< 1, -3>
position=< 32307,  10866> velocity=<-3, -1>
position=< 43039, -21318> velocity=<-4,  2>
position=< 32303, -32038> velocity=<-3,  3>
position=<-21320,  21594> velocity=< 2, -2>
position=<-10574, -42764> velocity=< 1,  4>
position=<-21332,  43045> velocity=< 2, -4>
position=<-21344, -10587> velocity=< 2,  1>
position=< 43030, -42767> velocity=<-4,  4>
position=<-53484, -21319> velocity=< 5,  2>
position=< 43058,  53777> velocity=<-4, -5>
position=<-21341,  32321> velocity=< 2, -3>
position=<-10583, -21319> velocity=< 1,  2>
position=<-32054, -10591> velocity=< 3,  1>
position=<-53491, -53496> velocity=< 5,  5>
position=<-42742,  43050> velocity=< 4, -4>
position=<-32026, -10583> velocity=< 3,  1>
position=< 10853,  21594> velocity=<-1, -2>
position=<-53483,  32321> velocity=< 5, -3>
position=<-21284, -21310> velocity=< 2,  2>
position=< 32323,  43051> velocity=<-3, -4>
position=< 32352,  53779> velocity=<-3, -5>
position=< 21612,  21594> velocity=<-2, -2>
position=< 32316,  43048> velocity=<-3, -4>
"""

// This is the code to print the challenge solution, but even the first iteration is taking too long. Moving to main.swift. Even in main.swift this takes too long to run, going to investigate ways of waiting until the points are ready before printing.
/*
do {
    var points = try Point.pointArray(from: part1Input)
    for _ in 0...4 {
        print(try Point.grid(from: points, pointCharacter: "●", blankCharacter: " "))
        points = Point.nextGeneration(from: points)
    }
} catch {
    print(error)
}
*/

// This was some debug to work out when the challenge points reach a local minimum. It may be assumed that the answer would lie around this point. A smaller grid would also be easier to print.
/*
do {
    var points = try Point.pointArray(from: part1Input)
//    points.forEach { print($0) }
//    print(points.count)                     // 360
//    print(try Point.gridSize(from: points)) // (-53525.0, -53500.0, 107331.0, 107279.0)
//    print(points.first?.asInputString)      // Demonstrates that the asInputString computed property works correctly, effectively allowing a point to be 'saved' and re-used again later.
    
    var oldSize = try Point.gridSize(from: points)
    
    for _ in 0...1000 {
        points = Point.nextGeneration(from: points)
        let newSize = try Point.gridSize(from: points)
        if newSize.width > oldSize.width || newSize.height > oldSize.height {
            print("Grid has grown. Therefore previous generation was a minimum")
            print(newSize)
            break
        }
        oldSize = newSize
    }
    
    points.forEach { print($0.asInputString) } // Allows task to be resumed later
} catch {
    print(error)
}
*/

let increasedInSize = """
position=<137,138> velocity=<-5,-2>
position=<121,136> velocity=<-5,-5>
position=<118,139> velocity=<3,-5>
position=<169,131> velocity=<2,-4>
position=<120,139> velocity=<-1,4>
position=<132,130> velocity=<1,-5>
position=<114,132> velocity=<4,-5>
position=<148,147> velocity=<2,3>
position=<124,135> velocity=<2,-1>
position=<132,143> velocity=<1,2>
position=<162,142> velocity=<4,5>
position=<159,141> velocity=<1,2>
position=<122,139> velocity=<2,-5>
position=<143,142> velocity=<-4,1>
position=<132,143> velocity=<-2,2>
position=<155,132> velocity=<-5,-3>
position=<149,137> velocity=<-4,2>
position=<138,139> velocity=<1,2>
position=<112,142> velocity=<2,3>
position=<149,143> velocity=<5,4>
position=<161,139> velocity=<-5,-2>
position=<143,141> velocity=<-4,4>
position=<157,137> velocity=<3,2>
position=<156,142> velocity=<-4,-2>
position=<123,141> velocity=<-3,5>
position=<147,149> velocity=<-5,5>
position=<168,138> velocity=<2,-5>
position=<125,134> velocity=<4,-1>
position=<118,141> velocity=<5,-3>
position=<127,139> velocity=<5,-2>
position=<171,142> velocity=<4,3>
position=<110,145> velocity=<-4,5>
position=<164,137> velocity=<-4,-2>
position=<117,139> velocity=<-5,1>
position=<149,135> velocity=<3,-4>
position=<144,144> velocity=<-3,4>
position=<152,140> velocity=<-2,5>
position=<150,138> velocity=<-5,2>
position=<167,146> velocity=<1,3>
position=<116,144> velocity=<3,4>
position=<133,141> velocity=<-1,1>
position=<156,139> velocity=<-4,-5>
position=<112,136> velocity=<-2,1>
position=<146,144> velocity=<4,1>
position=<171,143> velocity=<5,1>
position=<108,138> velocity=<-2,-3>
position=<150,147> velocity=<4,3>
position=<120,141> velocity=<-2,1>
position=<161,134> velocity=<1,-5>
position=<173,133> velocity=<2,-2>
position=<162,142> velocity=<3,3>
position=<147,143> velocity=<2,-1>
position=<138,134> velocity=<-5,-5>
position=<147,139> velocity=<5,2>
position=<111,146> velocity=<-4,4>
position=<118,144> velocity=<-4,4>
position=<125,141> velocity=<-1,-2>
position=<128,138> velocity=<-2,-5>
position=<148,130> velocity=<5,-5>
position=<147,136> velocity=<2,1>
position=<155,143> velocity=<1,5>
position=<127,136> velocity=<5,1>
position=<162,144> velocity=<4,4>
position=<133,137> velocity=<-2,-3>
position=<130,138> velocity=<-4,-2>
position=<124,138> velocity=<-3,1>
position=<129,141> velocity=<3,2>
position=<138,145> velocity=<2,4>
position=<139,136> velocity=<5,-1>
position=<166,144> velocity=<5,5>
position=<127,138> velocity=<5,2>
position=<111,138> velocity=<1,2>
position=<141,142> velocity=<-1,4>
position=<122,138> velocity=<-4,2>
position=<145,141> velocity=<-5,-2>
position=<114,149> velocity=<3,5>
position=<141,145> velocity=<4,3>
position=<126,139> velocity=<4,3>
position=<131,137> velocity=<1,-5>
position=<161,142> velocity=<3,3>
position=<147,136> velocity=<-5,1>
position=<138,136> velocity=<2,-5>
position=<143,141> velocity=<1,5>
position=<131,139> velocity=<-3,-3>
position=<154,144> velocity=<-5,5>
position=<136,146> velocity=<-1,4>
position=<129,142> velocity=<3,4>
position=<173,130> velocity=<5,-5>
position=<111,130> velocity=<-3,-5>
position=<107,146> velocity=<-3,3>
position=<131,137> velocity=<3,-2>
position=<160,135> velocity=<-1,-4>
position=<137,136> velocity=<-5,-5>
position=<158,140> velocity=<-4,-4>
position=<131,135> velocity=<5,-5>
position=<135,146> velocity=<-4,2>
position=<168,134> velocity=<-1,-5>
position=<133,136> velocity=<-1,-3>
position=<145,138> velocity=<-2,-4>
position=<109,142> velocity=<-5,2>
position=<162,131> velocity=<1,-4>
position=<107,147> velocity=<-5,3>
position=<137,139> velocity=<-2,4>
position=<130,142> velocity=<4,-2>
position=<157,136> velocity=<2,1>
position=<146,136> velocity=<4,1>
position=<110,145> velocity=<-4,2>
position=<161,142> velocity=<-5,2>
position=<170,139> velocity=<4,-5>
position=<130,134> velocity=<-4,-1>
position=<118,138> velocity=<3,-3>
position=<106,143> velocity=<-5,-1>
position=<126,138> velocity=<-4,-4>
position=<165,140> velocity=<-3,1>
position=<130,138> velocity=<-1,-5>
position=<120,139> velocity=<-3,4>
position=<130,141> velocity=<-4,5>
position=<123,136> velocity=<-4,-1>
position=<163,137> velocity=<3,-2>
position=<139,146> velocity=<5,5>
position=<162,141> velocity=<-4,-3>
position=<164,141> velocity=<-2,5>
position=<136,138> velocity=<2,-3>
position=<138,139> velocity=<-4,-5>
position=<127,139> velocity=<1,3>
position=<152,146> velocity=<-2,2>
position=<118,136> velocity=<4,1>
position=<110,135> velocity=<-5,-1>
position=<115,140> velocity=<2,5>
position=<164,143> velocity=<-3,-1>
position=<123,140> velocity=<-3,2>
position=<165,142> velocity=<3,3>
position=<134,138> velocity=<-5,3>
position=<170,148> velocity=<2,4>
position=<113,142> velocity=<1,-2>
position=<148,132> velocity=<-2,-3>
position=<128,149> velocity=<-3,5>
position=<117,148> velocity=<2,4>
position=<146,135> velocity=<4,-4>
position=<160,147> velocity=<-1,3>
position=<114,142> velocity=<-5,-2>
position=<120,136> velocity=<-2,-3>
position=<124,139> velocity=<-2,2>
position=<110,143> velocity=<-5,3>
position=<133,145> velocity=<2,5>
position=<154,136> velocity=<-4,-2>
position=<112,138> velocity=<-1,3>
position=<159,134> velocity=<-3,-5>
position=<164,139> velocity=<1,-5>
position=<134,141> velocity=<-2,3>
position=<156,134> velocity=<-2,-4>
position=<120,144> velocity=<-2,2>
position=<137,140> velocity=<-5,3>
position=<147,135> velocity=<5,-1>
position=<148,143> velocity=<-3,-1>
position=<152,134> velocity=<-1,-5>
position=<158,136> velocity=<5,-3>
position=<161,134> velocity=<-1,-1>
position=<170,147> velocity=<1,3>
position=<152,142> velocity=<2,-1>
position=<150,134> velocity=<3,-2>
position=<145,142> velocity=<3,4>
position=<130,135> velocity=<-5,-5>
position=<148,139> velocity=<-3,-2>
position=<165,130> velocity=<-3,-5>
position=<158,144> velocity=<-1,5>
position=<114,133> velocity=<3,-2>
position=<150,143> velocity=<-2,-1>
position=<162,148> velocity=<4,5>
position=<132,141> velocity=<-5,-1>
position=<159,133> velocity=<4,-4>
position=<140,141> velocity=<2,5>
position=<118,148> velocity=<3,5>
position=<131,135> velocity=<5,-3>
position=<138,148> velocity=<4,4>
position=<134,141> velocity=<-3,4>
position=<154,135> velocity=<2,-5>
position=<165,148> velocity=<-3,4>
position=<165,145> velocity=<-1,3>
position=<110,141> velocity=<-4,-2>
position=<150,145> velocity=<-4,1>
position=<118,142> velocity=<3,-1>
position=<120,148> velocity=<-1,4>
position=<141,138> velocity=<-3,-1>
position=<126,139> velocity=<5,-5>
position=<139,135> velocity=<2,-2>
position=<164,147> velocity=<5,3>
position=<111,134> velocity=<1,-4>
position=<117,139> velocity=<4,-5>
position=<118,136> velocity=<-5,1>
position=<113,140> velocity=<1,5>
position=<164,139> velocity=<-2,-1>
position=<146,141> velocity=<-1,4>
position=<131,138> velocity=<-3,-5>
position=<150,142> velocity=<5,3>
position=<140,141> velocity=<-2,-1>
position=<157,139> velocity=<3,1>
position=<142,138> velocity=<-5,-5>
position=<171,134> velocity=<5,-1>
position=<116,140> velocity=<3,-4>
position=<155,140> velocity=<-3,5>
position=<168,148> velocity=<-2,4>
position=<127,131> velocity=<-4,-5>
position=<123,138> velocity=<-3,3>
position=<171,136> velocity=<5,-1>
position=<139,149> velocity=<-3,5>
position=<140,136> velocity=<-3,1>
position=<128,140> velocity=<-2,-2>
position=<171,136> velocity=<4,-3>
position=<118,133> velocity=<3,-3>
position=<121,139> velocity=<-1,-3>
position=<138,146> velocity=<-5,2>
position=<159,140> velocity=<1,-1>
position=<151,148> velocity=<-2,4>
position=<141,140> velocity=<-3,5>
position=<170,142> velocity=<4,4>
position=<158,142> velocity=<-2,-2>
position=<140,131> velocity=<-2,-5>
position=<121,136> velocity=<-1,1>
position=<145,135> velocity=<3,-5>
position=<135,137> velocity=<-4,2>
position=<145,139> velocity=<1,-5>
position=<124,134> velocity=<2,-4>
position=<110,140> velocity=<-2,-4>
position=<145,146> velocity=<-5,2>
position=<119,137> velocity=<-3,2>
position=<158,146> velocity=<-4,2>
position=<150,133> velocity=<-4,-2>
position=<171,139> velocity=<5,4>
position=<158,140> velocity=<-4,-4>
position=<118,136> velocity=<4,-4>
position=<146,132> velocity=<1,-3>
position=<129,136> velocity=<-2,-3>
position=<129,137> velocity=<-2,1>
position=<128,138> velocity=<-3,-3>
position=<124,143> velocity=<-4,5>
position=<142,132> velocity=<4,-4>
position=<159,140> velocity=<1,4>
position=<165,140> velocity=<-2,5>
position=<137,138> velocity=<-5,-3>
position=<137,137> velocity=<1,-4>
position=<125,144> velocity=<-4,4>
position=<135,148> velocity=<5,5>
position=<112,145> velocity=<-3,5>
position=<129,147> velocity=<-2,5>
position=<144,143> velocity=<-2,4>
position=<157,144> velocity=<-5,5>
position=<157,137> velocity=<-1,-1>
position=<146,142> velocity=<4,2>
position=<120,130> velocity=<-3,-5>
position=<108,143> velocity=<-2,5>
position=<165,141> velocity=<-2,-3>
position=<110,130> velocity=<-1,-5>
position=<142,140> velocity=<-2,-4>
position=<145,147> velocity=<-5,3>
position=<166,143> velocity=<-5,-1>
position=<171,141> velocity=<2,2>
position=<151,142> velocity=<4,-1>
position=<164,139> velocity=<4,4>
position=<144,138> velocity=<-2,3>
position=<121,140> velocity=<3,-2>
position=<130,139> velocity=<4,2>
position=<139,139> velocity=<-3,-5>
position=<128,138> velocity=<2,-1>
position=<164,149> velocity=<-4,5>
position=<163,144> velocity=<5,3>
position=<129,144> velocity=<3,2>
position=<165,132> velocity=<-5,-3>
position=<146,137> velocity=<3,-2>
position=<151,142> velocity=<4,4>
position=<153,130> velocity=<2,-5>
position=<126,141> velocity=<-5,4>
position=<118,138> velocity=<3,2>
position=<136,143> velocity=<2,5>
position=<127,143> velocity=<-4,5>
position=<112,148> velocity=<1,4>
position=<163,143> velocity=<5,1>
position=<172,132> velocity=<3,-3>
position=<137,140> velocity=<3,5>
position=<161,137> velocity=<3,-3>
position=<125,145> velocity=<3,2>
position=<164,133> velocity=<-2,-5>
position=<139,138> velocity=<1,-5>
position=<109,139> velocity=<-1,-3>
position=<135,148> velocity=<5,5>
position=<115,136> velocity=<5,-1>
position=<137,139> velocity=<3,-3>
position=<119,149> velocity=<-2,5>
position=<174,134> velocity=<4,-5>
position=<169,141> velocity=<3,2>
position=<123,141> velocity=<-3,4>
position=<130,134> velocity=<-4,-1>
position=<148,145> velocity=<1,4>
position=<149,138> velocity=<-1,-4>
position=<132,142> velocity=<3,1>
position=<128,138> velocity=<-1,-2>
position=<156,136> velocity=<1,-1>
position=<121,135> velocity=<-1,-2>
position=<139,140> velocity=<3,2>
position=<163,140> velocity=<5,-4>
position=<143,146> velocity=<-4,5>
position=<141,144> velocity=<-1,5>
position=<137,139> velocity=<-1,-4>
position=<158,145> velocity=<-1,1>
position=<129,140> velocity=<-2,1>
position=<154,146> velocity=<4,4>
position=<151,149> velocity=<-2,5>
position=<172,139> velocity=<3,-5>
position=<142,144> velocity=<-5,4>
position=<109,132> velocity=<-1,-4>
position=<118,146> velocity=<3,3>
position=<157,143> velocity=<5,-1>
position=<157,139> velocity=<2,-5>
position=<154,130> velocity=<-5,-5>
position=<132,141> velocity=<-3,2>
position=<119,139> velocity=<-3,-1>
position=<156,134> velocity=<-4,-5>
position=<131,147> velocity=<-3,5>
position=<142,143> velocity=<-5,5>
position=<123,139> velocity=<-3,-3>
position=<111,138> velocity=<1,1>
position=<121,143> velocity=<2,-1>
position=<120,145> velocity=<2,2>
position=<140,131> velocity=<-4,-4>
position=<143,142> velocity=<-3,3>
position=<150,143> velocity=<-4,5>
position=<110,136> velocity=<-3,1>
position=<125,139> velocity=<-1,-5>
position=<155,138> velocity=<-3,-1>
position=<163,137> velocity=<5,2>
position=<147,134> velocity=<4,-5>
position=<155,140> velocity=<5,-3>
position=<171,133> velocity=<5,-2>
position=<113,141> velocity=<3,3>
position=<153,148> velocity=<-1,4>
position=<112,138> velocity=<2,-1>
position=<164,132> velocity=<1,-3>
position=<123,138> velocity=<-3,-1>
position=<127,138> velocity=<-4,2>
position=<119,146> velocity=<-3,3>
position=<136,138> velocity=<2,-2>
position=<154,148> velocity=<1,4>
position=<124,133> velocity=<2,-4>
position=<112,141> velocity=<2,1>
position=<118,145> velocity=<-4,4>
position=<156,137> velocity=<5,2>
position=<146,137> velocity=<-4,-5>
position=<115,137> velocity=<2,-3>
position=<145,137> velocity=<1,2>
position=<130,137> velocity=<3,1>
position=<149,144> velocity=<5,5>
position=<170,138> velocity=<4,-4>
position=<158,145> velocity=<3,1>
position=<125,138> velocity=<-1,-2>
position=<157,137> velocity=<5,-3>
position=<172,146> velocity=<2,2>
position=<139,139> velocity=<-3,-4>
position=<168,139> velocity=<-3,-5>
position=<156,138> velocity=<-2,-2>
position=<132,136> velocity=<-3,-4>
"""

/*
do {
    var points = try Point.pointArray(from: increasedInSize)
    let previousPoints = Point.previousGeneration(from: points)
    print(try Point.grid(from: previousPoints, pointCharacter: "●", blankCharacter: " "))
    /*
      ●●●●      ●●●  ●    ●  ●    ●  ●●●●●   ●●●●●●  ●●●●●●  ●●●●●●
     ●    ●      ●   ●●   ●  ●   ●   ●    ●       ●  ●       ●
     ●           ●   ●●   ●  ●  ●    ●    ●       ●  ●       ●
     ●           ●   ● ●  ●  ● ●     ●    ●      ●   ●       ●
     ●           ●   ● ●  ●  ●●      ●●●●●      ●    ●●●●●   ●●●●●
     ●  ●●●      ●   ●  ● ●  ●●      ●    ●    ●     ●       ●
     ●    ●      ●   ●  ● ●  ● ●     ●    ●   ●      ●       ●
     ●    ●  ●   ●   ●   ●●  ●  ●    ●    ●  ●       ●       ●
     ●   ●●  ●   ●   ●   ●●  ●   ●   ●    ●  ●       ●       ●
      ●●● ●   ●●●    ●    ●  ●    ●  ●●●●●   ●●●●●●  ●●●●●●  ●●●●●●
    */
    
    // (GJNKBZEE) Correct!
} catch {
    print(error)
}
*/

// Unknowingly, I printed the answer to part 2 to in main.swift: 10727 (178.78 minutes) (2.98 hours) (probably less time than it took to program the solution...)
