public final class Tournament<Grammar: SomeGrammar> {

    public typealias EvaluatedItem = (genotype: AnyGenotype, score: Double)

    private let grammar: Grammar.Type
    private let size: Int

    public init(grammar: Grammar.Type, size: Int) {
        self.grammar = grammar
        self.size = size
    }

    public func apply(population: Population) throws -> AnyGenotype {
        let items = population.items
            .compactMap { item -> EvaluatedItem? in
                guard let score = item.score
                else { return nil }

                return (item.genotype, score)
            }

        guard items.count > 0
        else { throw Failure.notEnoughCandidates }

        var best = pickRandom(from: items)
        for _ in 1 ..< size {
            let candidate = pickRandom(from: items)
            if candidate.score > best.score {
                best = candidate
            }
        }

        return best.genotype
    }

    private func pickRandom(from items: [EvaluatedItem]) -> EvaluatedItem {
        assert(items.count > 0)

        let offset = rand(below: items.count)
        let index = items.index(items.startIndex, offsetBy: offset)

        return items[index]
    }

    public enum Failure: Error {

        case notEnoughCandidates
    }
}
