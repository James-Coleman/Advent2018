import Foundation

let letterTime: [String: Int] = ["A":1, "B":2, "C":3, "D":4, "E":5, "F":6, "G":7, "H":8, "I":9, "J":10, "K":11, "L":12, "M":13, "N":14, "O":15, "P":16, "Q":17, "R":18, "S":19, "T":20, "U":21, "V":22, "W":23, "X":24, "Y":25, "Z":26]

final class Step {
    let id: String
    var complete: Bool
    var requirements: Set<Step>
    var timeTaken: Int = 0
    weak var worker: Worker? = nil
    
    enum StepTimeError: Swift.Error {
        case letterTimeDoesNotExist(letter: String)
    }
    
    public func timeRemaining(example: Bool = false) throws -> Int {
        guard let letterTime = letterTime[id] else { throw StepTimeError.letterTimeDoesNotExist(letter: id) }
        return example ? (letterTime - timeTaken) : ((letterTime + 60) - timeTaken)
    }
    
    public func timeComplete(example: Bool = false) throws -> Bool {
        let timeRemaining = try self.timeRemaining(example: example)
        return timeRemaining == 0
    }
    
    public func allRequirementsTimeCompleteSelfTimeIncomplete(example: Bool = false) throws -> Bool {
        let timeWaiting = try requirements.filter { try $0.timeComplete(example: example) == false }
        let selfComplete = try self.timeComplete(example: example)
        return timeWaiting.isEmpty && selfComplete == false
    }
    
    public func requirementsCompleteSelfTimeIncompleteNilWorker(example: Bool = false) throws -> Bool {
        let timeWaiting = try requirements.filter { try $0.timeComplete(example: example) == false }
        let selfComplete = try self.timeComplete(example: example)
        let workerIsNil = worker == nil
        return timeWaiting.isEmpty && selfComplete && workerIsNil
    }
    
    public var allRequirementsComplete: Bool {
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty
    }
    
    public var allRequirementsAndSelfComplete: Bool {
        if complete {
            return true
        }
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty
    }
    
    public var allRequirementsCompleteSelfIncomplete: Bool {
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty && self.complete == false
    }
    
    init(id: String) {
        self.id = id
        self.complete = false
        self.requirements = []
    }
}

final class Worker {
    private (set) var stepInProgress: Step? = nil
    
    public func assign(step: Step) {
        step.worker = self
        stepInProgress = step
    }
    
    public func incrementStepTime(example: Bool = false) throws -> String? {
        stepInProgress?.timeTaken += 1
        
        if let timeRemaining = try stepInProgress?.timeRemaining(example: example), timeRemaining == 0 {
            let id = stepInProgress?.id
            stepInProgress?.worker = nil
            stepInProgress = nil
            return id
        }
        
        return nil
    }
}

extension Step: Equatable {
    static func ==(lhs: Step, rhs: Step) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Step: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/*
extension Worker: CustomStringConvertible {
    var description: String {
        return """
        Worker(stepInProgress: \(stepInProgress)
        """
    }
}
*/

extension Step: CustomStringConvertible {
    var description: String {
        return """
        Step(id: \(id), complete: \(complete), requirements: \(requirements), timeTaken: \(timeTaken), timeRemaining: \(try? timeRemaining()) (cannot pass through example, this will include 60 seconds), worker: \(worker)
        """
    }
}

/*
 var example = Step(id: "A", complete: false, requirements: [])
 example.complete = true
 example.complete
 */

let exampleInput = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""

struct StepSeed {
    let id: String
    let requirement: String
    
    enum StepSeedInitError: Swift.Error {
        /// After splitting, the count of the seed string should be 3
        /// If that is not the case, this error will include the actual count
        case wrongSplitCount(count: Int)
    }
    
    init(seed: String) throws {
        let characterSet = CharacterSet.lowercaseLetters.union(CharacterSet.whitespaces.union(CharacterSet.punctuationCharacters))
        let idSplit = seed.components(separatedBy: characterSet)
        let withoutEmpty = idSplit.filter { $0.isEmpty == false }
        //        print(withoutEmpty)
        guard withoutEmpty.count == 3 else { throw StepSeedInitError.wrongSplitCount(count: withoutEmpty.count) }
        
        self.id = withoutEmpty[2]
        self.requirement = withoutEmpty[1]
    }
}

func stepsFrom(input: String) throws -> [Step] {
    var stepsToReturn: [Step] = []
    
    let lines = input.split(separator: "\n").map { String($0) }
    let seeds = try lines.map { try StepSeed(seed: $0) }
    
    for seed in seeds {
        
        var (step, newStep): (Step, Bool) = {
            if let existingStep = (stepsToReturn.filter { $0.id == seed.id }).first {
                return (existingStep, false)
            } else {
                let newStep = Step(id: seed.id)
                return (newStep, true)
            }
        }()
        
        var (requirement, newRequirement): (Step, Bool) = {
            if let existingStep = (stepsToReturn.filter { $0.id == seed.requirement }).first {
                return (existingStep, false)
            } else {
                let newStep = Step(id: seed.requirement)
                return (newStep, true)
            }
        }()
        
        step.requirements.insert(requirement)
        
        if newStep {
            stepsToReturn.append(step)
        }
        
        if newRequirement {
            stepsToReturn.append(requirement)
        }
    }
    
    return stepsToReturn
}

// This has been moved to the below Array extension
/*
 func stepWithNoRequirements(from: [Step]) -> Step? {
 let noRequirements = from.filter { $0.requirements.count == 0 }
 return noRequirements.first
 }
 
 func allStepsCompleted(from: [Step]) -> Bool {
 return from.filter { $0.complete == false }.count == 0
 }
 */

extension Array where Element: Step {
    /// This is actually fairly useless but was important to test
    var firstStepWithNoRequirements: Step? {
        let noRequirements = self.filter { $0.requirements.count == 0 }
        return noRequirements.first
    }
    
    /// A helper that returns the Steps sorted alphabetically by ID
    var sortedAlphabetically: [Step] {
        return self.sorted { $0.id < $1.id }
    }
    
    var allStepsCompleted: Bool {
        return self.filter { $0.complete == false }.count == 0
    }
    
    var nextAvailableStep: Step? {
        let availableSteps = self.filter { $0.allRequirementsCompleteSelfIncomplete }
//        let sortedAvailableSteps = availableSteps.sorted { $0.id < $1.id }
        let sortedAvailableSteps = availableSteps.sortedAlphabetically
        return sortedAvailableSteps.first
    }
    
    var allAvailableSteps: [Step] {
        let availableSteps = self.filter { $0.allRequirementsCompleteSelfIncomplete }
//        let sortedAvailableSteps = availableSteps.sorted { $0.id < $1.id }
        let sortedAvailableSteps = availableSteps.sortedAlphabetically
        return sortedAvailableSteps
    }
    
    var correctOrder: String {
        let stepArray = self
        
        var stringToReturn = ""
        
        while let nextAvailableStep = stepArray.nextAvailableStep {
            stringToReturn += nextAvailableStep.id
            nextAvailableStep.complete = true
        }
        
        return stringToReturn
    }
    
    func allReadySteps(example: Bool = false) throws -> [Step] {
        let availableSteps = try self.filter { try $0.allRequirementsTimeCompleteSelfTimeIncomplete(example: example) }
        let sortedAvailableSteps = availableSteps.sortedAlphabetically
        return sortedAvailableSteps
    }
    
    var unassigned: [Step] {
        return self.filter { $0.worker == nil }
    }
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /// From (StackOverflow)[https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings/25330930#25330930]
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func correctOrder(from: [Step]) -> String {
    let stepArray = from
    
    var stringToReturn = ""
    
    while let nextAvailableStep = stepArray.nextAvailableStep {
        stringToReturn += nextAvailableStep.id
        nextAvailableStep.complete = true
    }
    
    return stringToReturn
}

func example() {
    
    do {
        let steps = try stepsFrom(input: exampleInput)
        steps.count
        //    print(steps)
        //    print(steps.firstStepWithNoRequirements)
//        print(steps.nextAvailableStep)
        print(correctOrder(from: steps)) // Prints "CABDFE" (correct)
    } catch {
        print(error)
    }
    
}

//example()

let input = """
Step P must be finished before step G can begin.
Step X must be finished before step V can begin.
Step H must be finished before step R can begin.
Step O must be finished before step W can begin.
Step C must be finished before step F can begin.
Step U must be finished before step M can begin.
Step E must be finished before step W can begin.
Step F must be finished before step J can begin.
Step W must be finished before step K can begin.
Step R must be finished before step M can begin.
Step I must be finished before step K can begin.
Step D must be finished before step B can begin.
Step Z must be finished before step A can begin.
Step A must be finished before step N can begin.
Step T must be finished before step J can begin.
Step B must be finished before step N can begin.
Step Y must be finished before step M can begin.
Step Q must be finished before step N can begin.
Step G must be finished before step V can begin.
Step J must be finished before step N can begin.
Step M must be finished before step V can begin.
Step N must be finished before step V can begin.
Step K must be finished before step S can begin.
Step V must be finished before step L can begin.
Step S must be finished before step L can begin.
Step W must be finished before step D can begin.
Step A must be finished before step V can begin.
Step T must be finished before step Y can begin.
Step H must be finished before step W can begin.
Step O must be finished before step C can begin.
Step P must be finished before step S can begin.
Step Z must be finished before step N can begin.
Step G must be finished before step K can begin.
Step I must be finished before step T can begin.
Step D must be finished before step M can begin.
Step A must be finished before step Q can begin.
Step O must be finished before step S can begin.
Step N must be finished before step L can begin.
Step V must be finished before step S can begin.
Step M must be finished before step N can begin.
Step A must be finished before step B can begin.
Step H must be finished before step B can begin.
Step H must be finished before step G can begin.
Step Q must be finished before step M can begin.
Step U must be finished before step E can begin.
Step C must be finished before step S can begin.
Step M must be finished before step L can begin.
Step T must be finished before step L can begin.
Step I must be finished before step N can begin.
Step Y must be finished before step N can begin.
Step K must be finished before step V can begin.
Step U must be finished before step B can begin.
Step H must be finished before step Z can begin.
Step H must be finished before step Y can begin.
Step E must be finished before step F can begin.
Step F must be finished before step Q can begin.
Step R must be finished before step G can begin.
Step T must be finished before step S can begin.
Step T must be finished before step Q can begin.
Step X must be finished before step H can begin.
Step Q must be finished before step S can begin.
Step Q must be finished before step J can begin.
Step G must be finished before step S can begin.
Step D must be finished before step S can begin.
Step A must be finished before step J can begin.
Step I must be finished before step Y can begin.
Step U must be finished before step K can begin.
Step P must be finished before step R can begin.
Step A must be finished before step T can begin.
Step J must be finished before step K can begin.
Step Z must be finished before step J can begin.
Step Z must be finished before step V can begin.
Step P must be finished before step X can begin.
Step E must be finished before step I can begin.
Step G must be finished before step L can begin.
Step G must be finished before step N can begin.
Step J must be finished before step L can begin.
Step I must be finished before step Q can begin.
Step Q must be finished before step K can begin.
Step B must be finished before step J can begin.
Step R must be finished before step T can begin.
Step Z must be finished before step K can begin.
Step J must be finished before step V can begin.
Step R must be finished before step L can begin.
Step R must be finished before step N can begin.
Step W must be finished before step Q can begin.
Step U must be finished before step W can begin.
Step Y must be finished before step V can begin.
Step C must be finished before step T can begin.
Step X must be finished before step B can begin.
Step M must be finished before step S can begin.
Step B must be finished before step K can begin.
Step D must be finished before step N can begin.
Step P must be finished before step U can begin.
Step N must be finished before step K can begin.
Step M must be finished before step K can begin.
Step C must be finished before step A can begin.
Step W must be finished before step B can begin.
Step C must be finished before step Y can begin.
Step T must be finished before step V can begin.
Step W must be finished before step M can begin.
"""

func part1() {
    
    do {
        let steps = try stepsFrom(input: input)
        print(steps.correctOrder) // Prints "OCPUEFIXHRGWDZABTQJYMNKVSL" (correct!)
    } catch {
        print(error)
    }
}

//part1()

func solve(steps: [Step], with workers: [Worker], example: Bool = false) throws -> (sequence: String, time: Int) {
    var availableSteps = try steps.allReadySteps(example: example)
    
    var completedOrder: String = ""
    var secondsElapsed: Int = 0
    
    while availableSteps != [] {
        let unassignedSteps = availableSteps.unassigned
        
        var unassignedIndex: Int = 0
        
        forLoop:
            for (workerIndex, worker) in workers.enumerated() {
                if worker.stepInProgress == nil {
                    if let step = unassignedSteps[safe: unassignedIndex] {
                        worker.assign(step: step)
                        unassignedIndex += 1
                    } else {
                        break forLoop
                    }
                }
        }
        
        for worker in workers {
            let completedID = try worker.incrementStepTime(example: example)
            if let completedID = completedID {
                completedOrder += completedID
            }
        }
        
        secondsElapsed += 1
        
        availableSteps = try steps.allReadySteps(example: example)
    }
    
    return (completedOrder, secondsElapsed)
}

func part2Example() {
    
    do {
        let steps = try stepsFrom(input: exampleInput)
        let workers = [Worker(), Worker()]
//        let worker = Worker()
//        let workersTest = Array(repeating: Worker(), count: 2) // I think this is assigning the same worker (due to being passed by copy), therefore for every cycle of incrementStepTime it is incrementing twice.
//        print(workers, workersTest)
//        let workers = Array(repeating: worker, count: 2)
        
        let (completedOrder, secondsElapsed) = try solve(steps: steps, with: workers, example: true)
        
        print("Completed: \(completedOrder) in \(secondsElapsed) seconds") // Prints "Completed: CABFDE in 15 seconds" (correct!)
    } catch {
        print(error)
    }
}

//part2Example()

func part2() {
    do {
        let steps = try stepsFrom(input: input)
        let workers = [Worker(), Worker(), Worker(), Worker(), Worker()]
        
        let (completedOrder, secondsElapsed) = try solve(steps: steps, with: workers, example: false)
        
        print("Completed: \(completedOrder) in \(secondsElapsed) seconds") // Prints "Completed: OPCUXEHFIRWZGDABTQYJMNKVSL in 991 seconds" (Correct!)
        
    } catch {
        print(error)
    }
}

//part2()
