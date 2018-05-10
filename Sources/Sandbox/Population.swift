public final class Population {

    public typealias Evaluation = (AnyGenotype) -> Double
    public typealias Item = (genotype: AnyGenotype, score: Double?)

    public var items = [Item]()
    
    private let evaluate: Evaluation

    public init<Grammar>(_ randomGenotypeFactory: RandomGenotypeFactory<Grammar>, count: Int, evaluation: @escaping Evaluation) throws {
        self.evaluate = evaluation
        self.items.reserveCapacity(count)

        var hashSet = Set<Int>()

        for _ in 0 ..< count {
            // FIXME: 100
            try attempt(limit: 100) { retry in
                let (genotype, hash) = try randomGenotypeFactory.make()

                if !hashSet.contains(hash) {
                    let item = Item(genotype: genotype, score: nil)
                    items.append(item)
                    hashSet.insert(hash)
                } else {
                    try retry()
                }
            }
        }
    }

    public func evaluateAll() {
        items = items.map { item in
            if item.score != nil {
                return item
            } else {
                return Item(genotype: item.genotype, score: evaluate(item.genotype))
            }
        }
    }

    public func sort() {
        items.sort(by: { a, b in
            switch (a.score, b.score) {
            case (nil, _):
                return false
            case (.some, nil):
                return true
            case let (.some(aScore), .some(bScore)):
                return aScore > bScore
            }
        })
    }

    public var best: Item? {
        return items.reduce(into: Item?.none, { result, item in
            if let itemScore = item.score, result?.score.map({ $0 < itemScore }) ?? true {
                result = item
            }
        })
    }

    public var averageScore: Double {
        return items.reduce(into: 0.0, { result, item in result += item.score ?? 0 }) / Double(items.count)
    }
}
