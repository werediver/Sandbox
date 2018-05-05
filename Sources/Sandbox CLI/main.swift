import Sandbox
import Ant
import class Foundation.Thread

func clearScreen() { print("\u{1B}[2J") }

final class AntGenotypeEvaluator {

    let evaluator = AntEvaluator.santaFeAntTrail
    let antFactory = PhenotypeFactory(grammar: AntGrammar.self)

    func evaluate(_ genotype: AnyGenotype) -> Double {
        return evaluate(genotype, demo: false)
    }

    func evaluate(_ genotype: AnyGenotype, demo: Bool) -> Double {
        guard let ant = try? antFactory.make(from: genotype)
        else { return -Double.infinity }

        let score = evaluator.evaluate(ant, onChange: demo ? AntGenotypeEvaluator.draw : nil)

        if demo {
            print("Score: \(score)")
            print("Ant:\n\(ant)")
        }

        return score
    }

    static func draw(_ env: AntEnvironment) {
        clearScreen()
        print(env.field)
        Thread.sleep(forTimeInterval: 0.01)
    }
}

func reportBest(of pop: Population) {
    if let best = pop.best {
        print("Score: \(best.score ?? .nan)")

        let ant = try! PhenotypeFactory(grammar: AntGrammar.self).make(from: best.genotype)

        print("Ant:\n\(ant)")
    }
}

let randomGenotypeFactory = RandomGenotypeFactory(grammar: AntGrammar.self)
let mutation = Mutation(grammar: AntGrammar.self)
let antGenotypeEvaluator = AntGenotypeEvaluator()

let popCount = 500
let keepCount = Int((Double(popCount) * 0.25).rounded())
let mutateCount = popCount - keepCount

let pop = try Population(randomGenotypeFactory, count: popCount, evaluation: antGenotypeEvaluator.evaluate)
pop.evaluateAll()
pop.sort()
reportBest(of: pop)
for gen in 0 ..< 50 {
    print("Generation \(gen + 1)")
    pop.items = Array(pop.items.prefix(keepCount)) + pop.items.prefix(mutateCount).map { item in
        let mutatedGenotype = try! mutation.apply(to: item.genotype)
        return Population.Item(genotype: mutatedGenotype, score: nil)
    }
    pop.evaluateAll()
    pop.sort()
    reportBest(of: pop)
}

if let best = pop.best {
    _ = antGenotypeEvaluator.evaluate(best.genotype, demo: true)
}
