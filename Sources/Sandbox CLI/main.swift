import Sandbox
import Ant
import class Foundation.Thread

//func mutate<Grammar: SomeGrammar>(genotype: Genotype, grammar: Grammar.Type) throws -> Genotype {
//    let subtreeScanner = SubtreeScanner(genotype)
//    _ = try grammar.generate(subtreeScanner)
//
//    let targetSubtreeOffset = rand(below: genotype.codons.count)
//    let targetSubtreeSize = subtreeScanner.subtreeSize[targetSubtreeOffset]
//
//    let mutator = SubtreeMutator(genotype, subtree: targetSubtreeOffset, size: targetSubtreeSize)
//
//    _ = try grammar.generate(mutator)
//
//    return mutator.genotype
//}

func clearScreen() { print("\u{1B}[2J") }

final class AntGenotypeEvaluator {

    let evaluator = AntEvaluator.santaFeAntTrail
    let antFactory = PhenotypeFactory(grammar: AntGrammar.self)

    func evaluate(_ genotype: AnyGenotype, demo: Bool) throws -> Double {
        let ant = try antFactory.make(from: genotype)

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

let antGenotypeEvaluator = AntGenotypeEvaluator()

let randomGenotypeFactory = RandomGenotypeFactory(grammar: AntGrammar.self)

let population = try (0 ..< 100).map { _ in try randomGenotypeFactory.make() }
let scores = try population.map { try antGenotypeEvaluator.evaluate($0, demo: false) }
let bestScore = scores.max()!
let bestIndex = scores.index(of: bestScore)!
_ = try antGenotypeEvaluator.evaluate(population[bestIndex], demo: true)


//for _ in 0 ..< 10 {
//    let genotype = try! RandomGenotypeFactory(grammar: grammar).make()
//    let phenotypeFactory = PhenotypeFactory(grammar: grammar)
//    let phenotype = try! phenotypeFactory.make(from: genotype)
//
//    let mutated = try! mutate(genotype: genotype, grammar: grammar)
//    let mutatedPhenotype = try! phenotypeFactory.make(from: mutated)
//
//    print("Original:\n\(phenotype)")
//    print("Mutated:\n\(mutatedPhenotype)")
//}
