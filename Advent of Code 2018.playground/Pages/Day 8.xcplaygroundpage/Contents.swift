import Foundation

enum NodeError: Swift.Error {
    case isNotInt(string: String)
    case remainingStringIsEmptyButParentDoesNotExist
    case notEnoughHeaders
    case noInputStringOrIntArray
}

extension ArraySlice where Element: StringProtocol {
    var joinedWithSpace: String {
        return self.reduce("") { "\($0) \($1)" }
    }
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
    
    func headers() throws -> (childCount: Int, metaCount: Int) {
        let ints = try self.intArray()
        guard ints.count >= 2 else { throw NodeError.notEnoughHeaders }
        return (ints[0], ints[1])
    }
    
    var withoutHeaders: String {
        return String(self.suffix(self.count - 2))
    }
}

extension Array where Element == Int {
    func headers() throws -> (childCount: Int, metaCount: Int) {
        guard self.count >= 2 else { throw NodeError.notEnoughHeaders }
        return (self[0], self[1])
    }
}

struct Node {
    let childCount: Int
    var children: [Node]
    let metaCount: Int
    var metadata: [Int]?
  
    /*
    init(string: String) throws {
        let splitString = string.split(separator: " ").map { String($0) }
        
    }
    */
    
    /// The total number of children that this node has, including all generations of descendants (grandchildren, great-grandchildren etc)
    var descendantCount: Int {
        let childCounts = children.map { $0.childCount }
        let childSum = childCounts.reduce(0, +)
        return childSum + childCount
    }
    
    var sumOfMetadata: Int {
        let childSums = children.map { $0.sumOfMetadata }
        guard let metadata = metadata else { return 0 }
        let all = childSums + metadata
        return all.reduce(0, +)
    }
    
    var descendantMetaCount: Int {
        let childCounts = children.map { $0.metaCount }
        let childSum = childCounts.reduce(0, +)
        return childSum + metaCount
    }
    
    /**
     This would be nice to prettify the debug, but it doesn't work yet. (it's returning the new line and tab characters as raw strings)
     */
    func recursiveDescription(depth: Int = 0) -> String {
        let childrenDescription = children.map { $0.recursiveDescription(depth: depth + 1) }
        let indent = String(repeating: "\t", count: depth)
        return """
        Node(children:
        \(indent)\(childrenDescription),
        metaData: \(metadata),
        metaCount: \(metaCount)
        """
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
                
                let thisNode = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: metaIntArray)
                
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
                
                var node = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: metaIntArray)
                
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
    
    static func stringDecoder4(remainingString: String, parent: Node? = nil) throws -> [Node] {
        if remainingString == "" {
            guard let parent = parent else { throw NodeError.remainingStringIsEmptyButParentDoesNotExist }
            return [parent]
        } else {
            let splitString = remainingString.split(separator: " ").map { String($0) }
            
            let childString = splitString[0]
            guard let childInt = Int(childString) else { throw NodeError.isNotInt(string: childString) }
            
            let metaString = splitString[1]
            guard let metaInt = Int(metaString) else { throw NodeError.isNotInt(string: metaString) }
            
            // Make the node start and ends now
            
            let nodeIsChildless = childInt == 0
            
            func thisNodeMeta() throws -> [Int] {
                var meta: ArraySlice<String> {
                    if nodeIsChildless {
                        let thisNodeAsString = splitString.prefix(2 + metaInt)
                        return thisNodeAsString.suffix(metaInt)
                    } else {
                        // The meta is at the end of the remaining string
                        // FIXME: This won't work if the node has children and siblings. I.e. it will look at the end of the string to try and find the meta but it may find a siblings meta. I think we will need to know the meta count of all siblings children to find the actual meta data
                        return splitString.suffix(metaInt)
                    }
                }
                
                let metaIntArray = try meta.map { string -> Int in
                    guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
                    return int
                }
                
                return metaIntArray
            }
            
            var newNode: Node {
                if nodeIsChildless {
                    
                } else {
                    
                }
                
                return Node(childCount: childInt, children: [], metaCount: 0, metadata: [])
            }
            
            var stringStillRemaining: String {
                if nodeIsChildless {
                    
                } else {
                    
                }
                return ""
            }
            
            // Check afterwards if there are still siblings.
            // Return whole 'generation' at once.
            
            
        }
        
        return []
    }
    
    static func stringDecoder3(remainingString: String, parent: Node? = nil) throws -> [Node] {
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
                
                let thisNode = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: metaIntArray)
                
//                print("this node: \(thisNode)")
                
                let remainingInts: ArraySlice<String> = splitString[(2 + metaInt)...]
                let recombinedString = remainingInts.reduce("") { "\($0) \($1)" }
                
//                print("Recombined string: \(recombinedString)")
                
                let existingParentChildren = parent?.children ?? []
                let existingParentMeta = parent?.metadata ?? []
                let newParent = Node(childCount: childInt, children: existingParentChildren + [thisNode], metaCount: metaInt, metadata: existingParentMeta)
                
                return try Node.stringDecoder2(remainingString: recombinedString, parent: newParent)
            } else {
                // Take off the metaInt amount from the end
                let meta = splitString.suffix(metaInt)
                let metaIntArray = try meta.map { string -> Int in
                    guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
                    return int
                }
                
                let remaining = splitString[2...(splitString.count - metaInt - 1)]
                let remainingString = remaining.reduce("") { "\($0) \($1)" }
                
                var thisNode = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: metaIntArray)
                
                let existingParentChildren = parent?.children ?? []
                let existingParentMeta = parent?.metadata ?? []
                let newParent = Node(childCount: parent?.childCount ?? 0, children: existingParentChildren + [thisNode], metaCount: parent?.metaCount ?? 0, metadata: existingParentMeta)
                
                // Recurse
                let children = try Node.stringDecoder2(remainingString: remainingString, parent: newParent)
//                print("Children: \(children)")
                thisNode.children = children
                
                return [thisNode]
            }
        }
    }
    
    /**
     - parameter decodingChildren: If we know for certain that we are decoding a child node, this can be passed in as `true` and we will treat the start of the `remainingString` as the headers. Otherwise, they will be treated as possible meta data for the latest sibling.
     */
    static func stringDecoder5(string: String? = nil, ints: [Int]? = nil/*, decodingHeaders: Bool = true, parent: Node? = nil*/) throws -> Node {
        // I don't think this makes sense anymore, because we are not cutting off the end of the input string (only the start), we know exactly when the remainingString will be "" i.e. it will be at the very end of the process.
        /*
        if remainingString == "" {
            guard let parent = parent else { throw NodeError.remainingStringIsEmptyButParentDoesNotExist }
            return [parent]
        } else
        */
        
        /*
        if let parent = parent, parent.childCount == parent.children.count {
            // The parent is complete and should be returned
            // There might still be a string
            return [parent]
        } else {
            
            // while children.count < childCount
            // get the children by recursing
        }
        */
        
//        let ints = try remainingString.intArray()
        
        // Start at the beginning.
//        if decodingHeaders {
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
        
        let newNode = Node(childCount: childCount, children: children, metaCount: metaCount, metadata: metaData)
            
        return newNode
//        }
    }
    
    static func metaCountDecoder(remainingString: String, /*parent: Node? = nil,*/ siblings: [Node] = []) throws -> [Node] {
        if remainingString == "" {
            return siblings
        } else {
            let splitString = remainingString.split(separator: " ").map { String($0) }
            
            let childString = splitString[0]
            guard let childInt = Int(childString) else { throw NodeError.isNotInt(string: childString) }
            
            let metaString = splitString[1] // FIXME: This was failing becuase the function can't tell when it's finally worked through all the children/siblings and is now on the parent again. It was treating the parent meta data as another sibling.
            guard let metaInt = Int(metaString) else { throw NodeError.isNotInt(string: metaString) }
            
            // Need to work out the meta count of all children before calculating next sibling
            
            if childInt == 0 {
                // There are no child nodes so it's safe to take the first n characters of the string (after the child and meta headers)
                // The rest of the string will be the siblings
                
                let nodeArray = splitString.prefix(2 + metaInt) // childInt, metaInt, and the meta itself
                let metaArray = nodeArray.suffix(metaInt)
                let metaIntArray = try metaArray.map { string -> Int in
                    guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
                    return int
                }
                
                let newNode = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: metaIntArray) // All parameters are known for certain at this point.
                
                let restOfStringSlice = splitString.suffix(splitString.count - metaInt - 2)
                let restOfString = restOfStringSlice.joinedWithSpace
                
                let newSiblings = siblings + [newNode]
                
                // This will now be caught at the next recurse
                /*
                if restOfString == "" {
                    // There are no more siblings to calculate
                    return newSiblings
                } else {
                    // Continue to try and find the siblings
                    return try Node.metaCountDecoder(remainingString: restOfString, siblings: newSiblings)
                }
                */
                
                return try Node.metaCountDecoder(remainingString: restOfString, siblings: newSiblings)
            } else {
                // There are child nodes so you don't know exactly where the meta data is.
                // The child nodes and latter sibling nodes could interfere with the location of the meta data
                
                var newNode = Node(childCount: childInt, children: [], metaCount: metaInt, metadata: [])
                
                let restOfStringSlice = splitString.suffix(splitString.count - 2)
                let restOfString = restOfStringSlice.joinedWithSpace
                
                let children = try Node.metaCountDecoder(remainingString: restOfString)
                
                newNode.children = children
                
                return siblings + [newNode]
            }
        }
    }
    
    // This never came to anything, it was meant to count through the string until it finds the metadata, but I couldn't work out how make it work
    /*
    func metaDataExtractor(remainingString: String) throws -> [Int] {
        let splitString = remainingString.split(separator: " ").map { String($0) }
        
        let intArray = try splitString.map { string -> Int in
            guard let int = Int(string) else { throw NodeError.isNotInt(string: string) }
            return int
        }
        
        var childCount = intArray[0]
        
        var metaCount = intArray[1]
        
        guard metaCount > 0 else { return [] } // Return an empty array if it is known that there is no meta data
        
        var currentIndex = 2 // In theory the index will start at [2] i.e. immediately after the headers
        
        while childCount > 0 {
            // Initially need to look at children and work out if more need to be added to
            let newChild = intArray[currentIndex]
            let newMeta = intArray[currentIndex + 1]
            
            childCount += newChild
            
            if newChild == 0 {
                
            }
            
            if metaCount == 0 {
                
            }
        }
        
        // Assume everything is successful
        
    }
    */
}

extension Node: CustomStringConvertible {
    var description: String {
        return """
        Node(childCount: \(childCount), children: \(children), metaData: \(metadata), metaCount: \(metaCount))
        """
    }
}

struct StringNode {
    let id: String
    let children: [String]
    let seed: String
    let parentId: String?
    
    static let alphabet = ["A", "B", "C", "D"]
    
    static func stringDecoder(remainingString: String, completeNodes: [StringNode] = [], idIndex: Int = 0, parentId: String? = nil) throws -> [StringNode] {
        if remainingString == "" {
            return completeNodes
        } else {
            let splitString = remainingString.split(separator: " ").map { String($0) }
            
            let childString = splitString[0]
            guard let childInt = Int(childString) else { throw NodeError.isNotInt(string: childString) }
            
            let metaString = splitString[1]
            guard let metaInt = Int(metaString) else { throw NodeError.isNotInt(string: metaString) }
            
            if childInt == 0 {
                // Can safely remove this string from the front of the string and then recurse to find the siblings
                let thisNodeArray: ArraySlice<String> = splitString[...(metaInt + 1)]
                let thisNodeSeed = thisNodeArray.reduce("") { "\($0) \($1)" }
                
                let id = StringNode.alphabet[idIndex]
                let stringNode = StringNode(id: id, children: [], seed: thisNodeSeed, parentId: parentId)
                
                let remainingInts: ArraySlice<String> = splitString[(2 + metaInt)...]
                let recombinedString = remainingInts.reduce("") { "\($0) \($1)" }
                
                return try StringNode.stringDecoder(remainingString: recombinedString, completeNodes: completeNodes + [stringNode], idIndex: idIndex + 1, parentId: parentId)
            } else {
                // Take off the metaInt amount from the end
                let thisNodeStart = [childString, metaString]
                let thisNodeEnd = splitString.suffix(metaInt)
                let thisNodeSeed = (thisNodeStart + thisNodeEnd).reduce("") { "\($0) \($1)" }
                
                let id = StringNode.alphabet[idIndex]
                let stringNode = StringNode(id: id, children: [], seed: thisNodeSeed, parentId: parentId)
                
                let remaining = splitString[2...(splitString.count - metaInt - 1)]
                let remainingString = remaining.reduce("") { "\($0) \($1)" }
                
                // Recurse
                return try StringNode.stringDecoder(remainingString: remainingString, completeNodes: completeNodes + [stringNode], idIndex: idIndex + 1, parentId: id)
            }
        }
    }
}

extension StringNode: CustomStringConvertible {
    var description: String {
        return """
        StringNode(id: "\(id)", seed: "\(seed)", parentId: "\(parentId ?? "")"
        """
    }
}

let testString = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
let modifiedTestString = "2 3 1 3 0 1 98 10 11 12 1 1 0 1 99 2 1 1 2" // Has an extra child inside B.
let allSiblingsNoChildren = "0 1 1 0 1 1 0 1 1 0 1 1" // This test string is fundamentally flawed, there cannot be a tree without a root node. This is (1 reason) why it was failing
let oneParentThreeChildren = "1 3 0 3 1 2 3 0 3 4 5 6 0 3 7 8 9 10 11 12" // This test string was also flawed, it specified a single child, when it actually has 3
let oneParentThreeChildrenModified = "3 3 0 3 1 2 3 0 3 4 5 6 0 3 7 8 9 10 11 12" // This test string was also flawed, it specified a single child, when it actually has 3

/*
 The real input string is nearly 39_000 characters long, with nearly 19_000 seperate integers.
 It might not be imposible for there to be 3_000 layers.
 */

do {
//    print(try Node.stringDecoder(remainingString: testString)) // [" 2 3 1 1 2", " 0 3 10 11 12", " 1 1 2", " 0 1 99"]
    
    /*
    let nodes2 = try Node.stringDecoder2(remainingString: testString)
    print(nodes2)
    if let node2 = nodes2.first {
        print(node2.sumOfMetadata) // prints 138 (correct!)
    }
    */
    
//    print(try Node.stringDecoder(remainingString: allSiblingsNoChildren))   // This correctly decodes 4 nodes // [" 0 1 1", " 0 1 1", " 0 1 1", " 0 1 1"]
//    print(try Node.stringDecoder2(remainingString: allSiblingsNoChildren))  // This only decodes a single node (but with the correct meta) // [Node(children: [], metaData: [1]), metaCount: 1]
    
//    print(try Node.stringDecoder(remainingString: oneParentThreeChildren))  // This correctly decodes 4 nodes // [" 1 3 10 11 12", " 0 3 1 2 3", " 0 3 4 5 6", " 0 3 7 8 9"]
//    print(try Node.stringDecoder2(remainingString: oneParentThreeChildren)) // This only returns 2 nodes, the parent and the last child // [Node(children: [Node(children: [], metaData: [7, 8, 9]), metaCount: 3], metaData: [10, 11, 12]), metaCount: 3]
    
//    print(try StringNode.stringDecoder(remainingString: testString))
//    print(try StringNode.stringDecoder(remainingString: allSiblingsNoChildren))
//    print(try StringNode.stringDecoder(remainingString: oneParentThreeChildren))
//    print(try StringNode.stringDecoder(remainingString: modifiedTestString)) // Same thing as before is happening. It thinks the meta of B is actually the headers of a new Node
    
//    print(try Node.metaCountDecoder(remainingString: oneParentThreeChildren)) // Fatal error, see FIXME in metaCountDecoder
    
    let test = try Node.stringDecoder5(string: testString)                  // Success
    print(test)
    print(test.sumOfMetadata)                                               // Returns 138 (correct!)
    print(try Node.stringDecoder5(string: modifiedTestString))              // Success
    print(try Node.stringDecoder5(string: oneParentThreeChildrenModified))  // Success
    
/*
    let nodes3 = try Node.stringDecoder3(remainingString: testString)
    print(nodes3)
    if let node3 = nodes3.first {
        print(node3.sumOfMetadata) // used to print 138 (correct!), now prints 144
//        print(node.recursiveDescription())
    }
*/
    
} catch {
    print(error)
}

// stringDecoder2
/*
 [Node(children: [
    Node(children: [
        Node(children: [], metaData: [99])      // D
    ], metaData: [2]),                          // C
    Node(children: [], metaData: [10, 11, 12])  // B
 ], metaData: [1, 1, 2])]                       // A
 */

// stringDecoder3
/*
 [Node(children: [                                      // A meta but only 1 child
    Node(children: [                                    // C
        Node(children: [                                // ?
            Node(children: [], metaData: [1, 1, 2]),    // A meta but no children
            Node(children: [], metaData: [10, 11, 12]), // B
            Node(children: [], metaData: [2]),          // C meta but no children
            Node(children: [], metaData: [99])          // D
        ], metaData: [])
    ], metaData: [2])
 ], metaData: [1, 1, 2])]
 */

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
