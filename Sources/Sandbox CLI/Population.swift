import Sandbox

final class Population {

    typealias Evaluation = (AnyGenotype) -> Double

    struct Item {

        let genotype: AnyGenotype
        let score: Double?
    }

    var items = [Item]()
    private let evaluate: Evaluation

    init<Grammar>(_ randomGenotypeFactory: RandomGenotypeFactory<Grammar>, count: Int, evaluation: @escaping Evaluation) throws {
        self.evaluate = evaluation
        self.items.reserveCapacity(count)

        for _ in 0 ..< count {
            let genotype = try randomGenotypeFactory.make()
            let item = Item(genotype: genotype, score: nil)
            items.append(item)
        }
    }

    func evaluateAll() {
        items = items.map { item in
            if item.score != nil {
                return item
            } else {
                return Item(genotype: item.genotype, score: evaluate(item.genotype))
            }
        }
    }

    func sort() {
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

    var best: Item? {
        return items.reduce(into: Item?.none, { result, item in
            if let itemScore = item.score, result?.score.map({ $0 < itemScore }) ?? true {
                result = item
            }
        })
    }
}
