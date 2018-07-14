import Sandbox
import Ant

enum StoppingCriterion {

    case generation(Int)
    case score(Double)
    case either(score: Double, generation: Int)

    func isMet(score: Double, generation: Int) -> Bool {
        switch self {
        case let .generation(limit):
            return generation >= limit
        case let .score(target):
            return score >= target
        case let .either(target, limit):
            return score >= target || generation >= limit
        }
    }
}

func reportStats(_ pop: Population) {
//    var lengthMap = [Int: Int]()
//    for item in pop.items {
//        let length = item.genotype.codons.count
//        lengthMap[length] = (lengthMap[length] ?? 0) + 1
//    }
//    for length in lengthMap.keys.sorted() {
//        let count = lengthMap[length] ?? 0
//        let bar = repeatElement("#", count: count).joined()
//        print(String.init(format: "%3i:%3i %@", length, count, bar))
//    }

    if let best = pop.best {
        print("Average score: \(pop.averageScore)")
        print("Best score: \(best.score ?? .nan)")
        print("Best genotype length: \(best.genotype.codons.count)")

        //let ant = try! PhenotypeFactory(grammar: AntGrammar.self).make(from: best.genotype)

        //print("Best ant:\n\(ant)")
    }
}

func run(until stoppingCriterion: StoppingCriterion) throws -> Bool {

    let codonsCountLimit = 100
    let randomGenotypeFactory = RandomGenotypeFactory(grammar: AntGrammar.self, limit: codonsCountLimit)
    let tournament = Tournament(size: 2)
    let crossover = SubtreeCrossover(grammar: AntGrammar.self, limit: codonsCountLimit)
    let mutation = SubtreeLocalMutation(grammar: AntGrammar.self, limit: codonsCountLimit)
    let antGenotypeEvaluator = AntGenotypeEvaluator()

    let pop = Population(
            preferredCount: 500,
            randomGenotypeFactory: randomGenotypeFactory,
            evaluation: antGenotypeEvaluator.evaluate,
            eliteCount: 1,
            selection: tournament.apply,
            crossover: crossover.apply,
            mutation: mutation.apply,
            reproductionShaper: ReproductionShaper(profile: ReproductionProfile(generate: 0, crossover: 0.5, mutate: 0.25))
        )
    try pop.generateRandom()

    pop.evaluateAll()
    //reportStats(pop)

    var gen = 0
    while !stoppingCriterion.isMet(score: pop.best?.score ?? 0, generation: gen) {
        gen += 1
        //print("Generation \(gen)")

        try pop.generateNext()

        pop.evaluateAllConcurrently()
        //reportStats(pop)
    }

    if let best = pop.best, best.score.map({ $0 >= targetScore}) ?? false {
        //_ = antGenotypeEvaluator.evaluate(best.genotype, demo: true)
        //print("Genotype length: \(best.genotype.codons.count)")
        print("Found in generation \(gen)")
    }

    return (pop.best?.score ?? 0) >= targetScore
}

let targetScore: Double = 89
let stoppingCriterion = StoppingCriterion.either(score: targetScore, generation: 50)
//let goal = Goal.generation(50)

var runCount = 0
var successCount = 0

for _ in 0 ..< 100 {

    let success = try run(until: stoppingCriterion)

    runCount += 1
    successCount += success ? 1 : 0

    print("Success count / run count: \(successCount) / \(runCount), \(Double(successCount) / Double(runCount))")
}

//_ = antGenotypeEvaluator.evaluate(AntGrammar.referenceAnt, demo: true)
