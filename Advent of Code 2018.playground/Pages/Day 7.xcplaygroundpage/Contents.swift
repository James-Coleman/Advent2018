import Foundation

class Step {
    let id: String
    var complete: Bool
    var requirements: Set<Step>
    
    var allRequirementsComplete: Bool {
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty
    }
    
    var allRequirementsAndSelfComplete: Bool {
        if complete {
            return true
        }
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty
    }
    
    var allRequirementsCompleteSelfIncomplete: Bool {
        let incomplete = requirements.filter { $0.complete == false }
        return incomplete.isEmpty && self.complete == false
    }
    
    init(id: String) {
        self.id = id
        self.complete = false
        self.requirements = []
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

extension Step: CustomStringConvertible {
    var description: String {
        return """
        Step(id: \(id), complete: \(complete), requirements: \(requirements)
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
    
    var allStepsCompleted: Bool {
        return self.filter { $0.complete == false }.count == 0
    }
    
    var nextAvailableStep: Step? {
        let availableSteps = self.filter { $0.allRequirementsCompleteSelfIncomplete }
        let sortedAvailableSteps = availableSteps.sorted { $0.id < $1.id }
        return sortedAvailableSteps.first
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
        print(steps.nextAvailableStep)
        print(correctOrder(from: steps)) // Prints "CABDFE" (correct)
    } catch {
        print(error)
    }
    
}

func part1() {
    let part1Input = """
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
    
    do {
        let steps = try stepsFrom(input: part1Input)
        print(steps.correctOrder) // Prints "OCPUEFIXHRGWDZABTQJYMNKVSL" (correct!)
    } catch {
        print(error)
    }
}

part1()
