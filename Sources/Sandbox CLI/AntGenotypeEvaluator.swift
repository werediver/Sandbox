import Sandbox
import Ant
import class Foundation.Thread

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

private func clearScrollBuffer() { print("\u{1B}[3J") }

private func clearScreen() {
    clearScrollBuffer()
    print("\u{1B}[2J")
}

//func clearLine() { print("\u{1B}[") }
