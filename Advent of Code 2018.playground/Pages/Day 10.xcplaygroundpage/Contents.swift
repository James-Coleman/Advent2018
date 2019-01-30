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
    
    public static func grid(from points: [Point]) throws -> String {
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
                    stringToReturn += "#"
                } else {
                    stringToReturn += "."
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
