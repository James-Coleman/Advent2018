import Foundation

enum NodeError: Swift.Error {
    case isNotInt(string: String)
    case remainingStringIsEmptyButParentDoesNotExist
    case notEnoughHeaders
    case noInputStringOrIntArray
}

extension String {
    /**
     Returns an array of integers from the string.
     
     Assumes the source string (`self`) is a string of integers seperated by a space.
     
     - throws: NodeError.isNotInt if it finds a string which cannot be cast to an Int.
     */
    func intArray() throws -> [Int] {
        let split = self.split(separator: " ")
        let strings = split.map { String($0) }
        let ints = try strings.map { string -> Int in
            guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
            return int
        }
        return ints
    }
}

struct Node {
    let children: [Node]
    let metaData: [Int]
  
    /*
    init(string: String) throws {
        let splitString = string.split(separator: " ").map { String($0) }
        
    }
    */
    
    /// The total number of children that this node has, including all generations of descendants (grandchildren, great-grandchildren etc)
    var descendantCount: Int {
        let childCounts = children.map { $0.descendantCount }
        let childSum = childCounts.reduce(0, +)
        return childSum + children.count
    }
    
    var sumOfMetadata: Int {
        let childSums = children.map { $0.sumOfMetadata }
        let all = childSums + metaData
        return all.reduce(0, +)
    }
    
    var descendantMetaCount: Int {
        let childCounts = children.map { $0.descendantMetaCount }
        let childSum = childCounts.reduce(0, +)
        return childSum + metaData.count
    }
    
    /**
     
     */
    static func stringDecoder5(string: String? = nil, ints: [Int]? = nil) throws -> Node {

        // Start at the beginning.
        func properIntsFunction() throws -> [Int] {
            if let ints = ints {
                return ints
            } else if let string = string {
                let intArray = try string.intArray()
                return intArray
            } else {
                throw NodeError.noInputStringOrIntArray
            }
        }
        
        let properInts = try properIntsFunction()
//        print("properInts:", properInts)
        
        guard properInts.count >= 2 else { throw NodeError.notEnoughHeaders }
        
        let (childCount, metaCount) = (properInts[0], properInts[1])
        
        var restOfInts = Array(properInts[2...])
        /*
        {
            didSet {
                print("restOfInts:", restOfInts)
            }
        }
        */
        
        var children: [Node] = []
        
        while children.count < childCount {
            let nextChild = try Node.stringDecoder5(ints: restOfInts)
//            print(nextChild)
            children += [nextChild]
            // Need to work out exactly how much of the string to strip out.
            // This will be the total number of children * 2 (for the headers) plus the total count of meta data
            let descendantCount = nextChild.descendantCount + 1 // + 1 to account for this child itself
            let totalHeaderCount = descendantCount * 2
            let descendantMetaCount = nextChild.descendantMetaCount
            let totalToRemove = totalHeaderCount + descendantMetaCount
            restOfInts = Array(restOfInts[totalToRemove...])
        }
        
        // The rest is meta
        
        let metaData = Array(restOfInts[..<metaCount])
        
        let newNode = Node(children: children, metaData: metaData)
            
        return newNode
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        return """
        Node(children: \(children), metaData: \(metaData))
        """
    }
}

let testString = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
let modifiedTestString = "2 3 1 3 0 1 98 10 11 12 1 1 0 1 99 2 1 1 2" // Has an extra child inside B.
let oneParentThreeChildren = "3 3 0 3 1 2 3 0 3 4 5 6 0 3 7 8 9 10 11 12"

/*
 The real input string is nearly 39_000 characters long, with nearly 19_000 seperate integers.
 It might not be imposible for there to be 3_000 layers.
 */

do {
    let test = try Node.stringDecoder5(string: testString)          // Success
    print(test)
    print(test.sumOfMetadata)                                       // Returns 138 (correct!)
    print(try Node.stringDecoder5(string: modifiedTestString))      // Success
    print(try Node.stringDecoder5(string: oneParentThreeChildren))  // Success
} catch {
    print(error)
}


// This confirms that the sumOfMetaData is working correctly.
// Now just to make it create the nodes themselves...
/*
Node(children: [
    Node(children: [], metadata: [10,11,12]),
    Node(children: [
        Node(children: [], metadata: [99])
        ], metadata: [2])
    ], metadata: [1,1,2])
        .sumOfMetadata
*/
