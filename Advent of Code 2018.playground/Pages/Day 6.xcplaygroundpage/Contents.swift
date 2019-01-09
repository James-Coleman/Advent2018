import Foundation

struct GridPoint {
    let x: Int
    let y: Int
    let id: String?
    let nearId: String?
    
    init(x: Int, y: Int, id: String? = nil, nearId: String? = nil) {
        self.x = x
        self.y = y
        self.id = id
        self.nearId = nearId
    }
    
    func distanceTo(point: GridPoint) -> Int {
        let xDifference = x - point.x
        let yDifference = y - point.y
        
        let xAbs = abs(xDifference)
        let yAbs = abs(yDifference)
        
        let total = xAbs + yAbs
        
        return total
    }
    
    func nearestPoint(in array: [GridPoint]) -> GridPoint? {
        let sortedPoints = array.sorted(by: { $0.distanceTo(point: self) < $1.distanceTo(point: self) })
        return sortedPoints.first
    }
    
    func equidistantFrom(points: [GridPoint]) -> Bool {
        guard points.count >= 2 else { return false } // Make sure there are at least 2 points in the array
        let sortedPoints = points.sorted(by: { $0.distanceTo(point: self) < $1.distanceTo(point: self) })
        let firstPoint = sortedPoints[0]
        let secondPoint = sortedPoints[1]
        return distanceTo(point: firstPoint) == distanceTo(point: secondPoint)
    }
}

extension GridPoint: Equatable {
    static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

struct Day6 {

    static func blankGrid(width: Int, height: Int) -> String {
        let row = Array(repeating: ".", count: width)
        let grid = Array(repeating: row, count: height)
        let lines = grid.reduce("") { (soFar, nextRow) -> String in
            return soFar + nextRow.joined() + "\n"
        }
        let withoutLastNewLine = lines.dropLast()
        let stringWithoutLastNewLine = String(withoutLastNewLine)
        return stringWithoutLastNewLine
    }
    
    static func drawBlankGrid(width: Int, height: Int) {
        let grid = Day6.blankGrid(width: width, height: height)
        print(grid)
    }
    
    static func grid(width: Int, height: Int, points: [GridPoint]) -> String {
        var stringToReturn = ""
        
        for row in 0..<height {
            for column in 0...width {
                if column == width {
                    stringToReturn += "\n"
                    continue
                }
                
                let point = GridPoint(x: column, y: row)
                if let existingPoint = points.first(where: {$0 == point}), let id = existingPoint.id {
                    stringToReturn += id
                } else if point.equidistantFrom(points: points) {
                    stringToReturn += "."
                } else if let nearestPoint = point.nearestPoint(in: points), let nearId = nearestPoint.nearId {
                    stringToReturn += nearId
                } else {
                    stringToReturn += "."
                }
            }
        }
        
        return stringToReturn
    }
    
    static func drawGrid(width: Int, height: Int, points: [GridPoint]) {
        let grid = Day6.grid(width: width, height: height, points: points)
        print(grid)
    }
    
    static func nearestPoint(to point: GridPoint, from array: [GridPoint]) -> GridPoint? {
        let sortedPoints = array.sorted(by: { $0.distanceTo(point: point) < $1.distanceTo(point: point) })
        return sortedPoints.first
    }
    
    static func gridPoints(from seed: String) -> [GridPoint] {
        var arrayToReturn = [GridPoint]()
        
        
        
        return arrayToReturn
    }
}

//Day6.drawBlankGrid(width: 10, height: 10)

let examplePoints = [
    GridPoint(x: 1, y: 1, id: "A", nearId: "a"),
    GridPoint(x: 1, y: 6, id: "B", nearId: "b"),
    GridPoint(x: 8, y: 3, id: "C", nearId: "c"),
    GridPoint(x: 3, y: 4, id: "D", nearId: "d"),
    GridPoint(x: 5, y: 5, id: "E", nearId: "e"),
    GridPoint(x: 8, y: 9, id: "F", nearId: "f")
]

Day6.drawGrid(width: 10, height: 10, points: examplePoints)

let day6Input = """
350, 353
238, 298
248, 152
168, 189
127, 155
339, 202
304, 104
317, 144
83, 106
78, 106
170, 230
115, 194
350, 272
159, 69
197, 197
190, 288
227, 215
228, 124
131, 238
154, 323
54, 185
133, 75
242, 184
113, 273
65, 245
221, 66
148, 82
131, 351
97, 272
72, 93
203, 116
209, 295
133, 115
355, 304
298, 312
251, 58
81, 244
138, 115
302, 341
286, 103
111, 95
148, 194
235, 262
41, 129
270, 275
234, 117
273, 257
98, 196
176, 122
121, 258
"""

day6Input.split(separator: "\n").count

let ids = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","Å","Œ","Â","Á","Ê","Æ","Ë","È","Ø","∏","Í","Î","Ï","Ì","Ó","Ô","Ò","Û","Ù","Ç","Ú","Ḅ","Ḍ","Ḟ"]
ids.count
let lowercaseIds = ids.map { $0.lowercased() }
print(lowercaseIds)
Set(ids).count == Set(lowercaseIds).count

