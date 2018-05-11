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

    let evaluator = AntEvaluator.santaFeAntTrail
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
        print(env.field)
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
let tournament = Tournament(grammar: AntGrammar.self, size: 7)
let crossover = Crossover(grammar: AntGrammar.self, limit: codonsCountLimit)
let mutation = Mutation(grammar: AntGrammar.self, limit: codonsCountLimit)
let antGenotypeEvaluator = AntGenotypeEvaluator()

let p = (crossover: 0.5, mutation: 0.5)
let popCount = 500
//let eliteCount = Int((Double(popCount) * 0.25).rounded())
let eliteCount = 1
let mutateCount = popCount - eliteCount

let pop = try Population(randomGenotypeFactory, count: popCount, evaluation: antGenotypeEvaluator.evaluate)
pop.evaluateAll()
pop.sort()
reportStats(pop)

for gen in 0 ..< 50 {
    print("Generation \(gen + 1)")

///*
    var nextGeneration = Array(pop.items.prefix(eliteCount))
    while nextGeneration.count < popCount {
        var genotype1 = try tournament.apply(population: pop)
        if urand() < p.crossover {
            let genotype2 = try tournament.apply(population: pop)

            guard let (genotype3, genotype4) = try? crossover.apply(to: genotype1, genotype2)
            else { continue }

            nextGeneration.append((genotype3, nil))
            nextGeneration.append((genotype4, nil))
        } else {
            if urand() < p.mutation {
                do {
                    genotype1 = try mutation.apply(to: genotype1)
                } catch {
                    continue
                }
            }
            nextGeneration.append((genotype1, nil))
        }
    }
    pop.items = nextGeneration
//*/

/*
    var nextGeneration = Array(pop.items.prefix(eliteCount))
    let reusePool = pop.items.prefix(mutateCount)
    //var offset = 0
    while nextGeneration.count < popCount {
        //let genotype = reusePool[offset % reusePool.count].genotype
        //defer { offset += 1 }
        let genotype = try tournament.apply(population: pop)
        do {
            let mutatedGenotype = try mutation.apply(to: genotype)
            nextGeneration.append(Population.Item(genotype: mutatedGenotype, score: nil))
        } catch {
            continue
        }
    }
    pop.items = nextGeneration
*/
    pop.evaluateAll()
    pop.sort()
    reportStats(pop)
}

if let best = pop.best {
    _ = antGenotypeEvaluator.evaluate(best.genotype, demo: true)
    print("Genotype length: \(best.genotype.codons.count)")
}

//_ = antGenotypeEvaluator.evaluate(AntGrammar.referenceAnt, demo: true)
