public final class Tournament {

    public typealias EvaluatedItem = (genotype: AnyGenotype, score: Double)

    private let size: Int

    public init(size: Int) {
        self.size = size
    }

    public func apply(to items: [Population.Item]) throws -> AnyGenotype {
        let evaluatedItems = items
            .compactMap { item -> EvaluatedItem? in
                guard let score = item.score
                else { return nil }

                return (item.genotype, score)
            }

        guard evaluatedItems.count > 0
        else { throw Failure.notEnoughCandidates }

        var best = pickRandom(from: evaluatedItems)
        for _ in 1 ..< size {
            let candidate = pickRandom(from: evaluatedItems)
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
