import Sandbox
import Ant
import class Foundation.Thread
import func Foundation.exit

func clearScrollBuffer() { print("\u{1B}[3J") }

func clearScreen() {
    clearScrollBuffer()
    print("\u{1B}[2J")
}

//func clearLine() { print("\u{1B}[") }

final class AntGenotypeEvaluator {

    let evaluator = AntEvaluator.santaFeTrail
    let antFactory = PhenotypeFactory(grammar: AntGrammar.self)

    func evaluate(_ genotype: AnyGenotype) -> Double {
        return evaluate(genotype, demo: false)
    }

    func evaluate(_ genotype: AnyGenotype, demo: Bool) -> Double {
        guard let ant = try? antFactory.make(from: genotype)
        else { return -Double.infinity }

        return evaluate(ant, demo: demo)
    }

    func evaluate(_ ant: AntBlock, demo: Bool) -> Double {
        let score = evaluator.evaluate(ant, onChange: demo ? AntGenotypeEvaluator.draw : nil)

        if demo {
            print("Score: \(score)")
            print("Ant:\n\(ant)")
        }

        return score
    }

    static func draw(_ env: AntEnvironment) {
        clearScreen()
        let fieldDescription = env.field.description(
            size: (
                rows: min(env.field.size.rows, 68),
                columns: min(env.field.size.columns, 68)
            )
        )
        print(fieldDescription)
        Thread.sleep(forTimeInterval: 0.02)
    }
}

func reportStats(_ pop: Population) {
    var lengthMap = [Int: Int]()
    for item in pop.items {
        let length = item.genotype.codons.count
        lengthMap[length] = (lengthMap[length] ?? 0) + 1
    }
    for length in lengthMap.keys.sorted() {
        let count = lengthMap[length] ?? 0
        let bar = repeatElement("#", count: count).joined()
        print(String.init(format: "%3i:%3i %@", length, count, bar))
    }

    if let best = pop.best {
        print("Average score: \(pop.averageScore)")
        print("Best score: \(best.score ?? .nan)")
        print("Best genotype length: \(best.genotype.codons.count)")

        //let ant = try! PhenotypeFactory(grammar: AntGrammar.self).make(from: best.genotype)

        //print("Best ant:\n\(ant)")
    }
}

let codonsCountLimit = 100
let randomGenotypeFactory = RandomGenotypeFactory(grammar: AntGrammar.self, limit: codonsCountLimit)
let tournament = Tournament(size: 2)
let crossover = Crossover(grammar: AntGrammar.self, limit: codonsCountLimit)
let mutation = Mutation(grammar: AntGrammar.self, limit: codonsCountLimit)
let antGenotypeEvaluator = AntGenotypeEvaluator()

let pop = Population(
        preferredCount: 500,
        eliteCount: 1,
        evaluation: antGenotypeEvaluator.evaluate,
        selection: tournament.apply,
        crossover: crossover.apply,
        mutation: mutation.apply,
        probabilities: (crossover: 0.5, mutation: 0.5)
    )
try pop.generateRandom(randomGenotypeFactory)

pop.evaluateAll()
pop.sort()
reportStats(pop)

var gen = 0
while (pop.best?.score ?? 0) < 89, gen < 50 {
    gen += 1
    print("Generation \(gen)")

    try pop.generateNext()

    pop.evaluateAll()
    pop.sort()
    reportStats(pop)
}

if let best = pop.best {
    _ = antGenotypeEvaluator.evaluate(best.genotype, demo: true)
    print("Genotype length: \(best.genotype.codons.count)")
    print("Found in generation \(gen)")
}

//_ = antGenotypeEvaluator.evaluate(AntGrammar.referenceAnt, demo: true)
