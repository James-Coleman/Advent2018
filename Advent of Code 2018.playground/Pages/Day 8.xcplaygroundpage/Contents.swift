import Foundation

struct Node {
    var children: [Node]
    let metadata: [Int]
  
    /*
    init(string: String) throws {
        let splitString = string.split(separator: " ").map { String($0) }
        
    }
    */
    
    var sumOfMetadata: Int {
        let childSums = children.map { $0.sumOfMetadata }
        let all = childSums + metadata
        return all.reduce(0, +)
    }
    
    enum NodeError: Swift.Error {
        case isNotInt(string: String)
        case remainingStringIsEmptyButParentDoesNotExist
    }
    
    static func stringDecoder(remainingString: String, completeStrings: [String] = []) throws -> [String] {
        if remainingString == "" {
            return completeStrings
        } else {
            let splitString = remainingString.split(separator: " ").map { String($0) }
            
            let childString = splitString[0]
            guard let childInt = Int(childString) else { throw NodeError.isNotInt(string: childString) }
            
            let metaString = splitString[1]
            guard let metaInt = Int(metaString) else { throw NodeError.isNotInt(string: metaString) }
            
            if childInt == 0 {
                // Can safely remove this string from the front of the string and then recurse to find the siblings
                let thisNodeArray: ArraySlice<String> = splitString[...(metaInt + 1)]
                let thisNode = thisNodeArray.reduce("") { "\($0) \($1)" }
                
                let remainingInts: ArraySlice<String> = splitString[(2 + metaInt)...]
                let recombinedString = remainingInts.reduce("") { "\($0) \($1)" }
                
                return try Node.stringDecoder(remainingString: recombinedString, completeStrings: completeStrings + [thisNode])
            } else {
                // Take off the metaInt amount from the end
                let thisNodeStart = [childString, metaString]
                let thisNodeEnd = splitString.suffix(metaInt)
                let combined = (thisNodeStart + thisNodeEnd).reduce("") { "\($0) \($1)" }
                
                let remaining = splitString[2...(splitString.count - metaInt - 1)]
                let remainingString = remaining.reduce("") { "\($0) \($1)" }
                
                // Recurse
                return try Node.stringDecoder(remainingString: remainingString, completeStrings: completeStrings + [combined])
            }
        }
    }
    
    static func stringDecoder2(remainingString: String, parent: Node? = nil) throws -> [Node] {
        if remainingString == "" {
            guard let parent = parent else { throw NodeError.remainingStringIsEmptyButParentDoesNotExist }
            return [parent]
        } else {
            let splitString = remainingString.split(separator: " ").map { String($0) }
            
            let childString = splitString[0]
            guard let childInt = Int(childString) else { throw NodeError.isNotInt(string: childString) }
            
            let metaString = splitString[1]
            guard let metaInt = Int(metaString) else { throw NodeError.isNotInt(string: metaString) }
            
            if childInt == 0 {
                // Can safely remove this string from the front of the string and then recurse to find the siblings
                
                let thisNodeAsString = splitString.prefix(2 + metaInt)
                let meta = thisNodeAsString.suffix(metaInt)
                let metaIntArray = try meta.map { string -> Int in
                    guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
                    return int
                }
                
                let thisNode = Node(children: [], metadata: metaIntArray)
                
//                print("this node: \(thisNode)")
                
                let remainingInts: ArraySlice<String> = splitString[(2 + metaInt)...]
                let recombinedString = remainingInts.reduce("") { "\($0) \($1)" }
                
//                print("Recombined string: \(recombinedString)")
                
                return try Node.stringDecoder2(remainingString: recombinedString, parent: thisNode)
            } else {
                // Take off the metaInt amount from the end
                let meta = splitString.suffix(metaInt)
                let metaIntArray = try meta.map { string -> Int in
                    guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
                    return int
                }
                
                let remaining = splitString[2...(splitString.count - metaInt - 1)]
                let remainingString = remaining.reduce("") { "\($0) \($1)" }
                
                var node = Node(children: [], metadata: metaIntArray)
                
                // Recurse
                let children = try Node.stringDecoder2(remainingString: remainingString)
//                print("Children: \(children)")
                node.children = children
                
                if let parent = parent {
                    return [node] + [parent]
                } else {
                    return [node]
                }
            }
        }
    }
}

let testString = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
do {
    print(try Node.stringDecoder(remainingString: testString)) // [" 2 3 1 1 2", " 0 3 10 11 12", " 1 1 2", " 0 1 99"]
    let nodes = try Node.stringDecoder2(remainingString: testString)
    if let node = nodes.first {
        print(node.sumOfMetadata) // prints 138 (correct!)
    }
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
