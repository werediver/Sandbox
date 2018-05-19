public final class Population {

    public typealias Evaluation = (AnyGenotype) -> Double
    public typealias Selection  = ([Item]) throws -> AnyGenotype
    public typealias Crossover  = (AnyGenotype, AnyGenotype) throws -> (AnyGenotype, AnyGenotype)
    public typealias Mutation   = (AnyGenotype) throws -> AnyGenotype

    public var items = [Item]()
    public let preferredCount: Int

    private let eliteCount: Int
    
    private let evaluate: Evaluation
    private let select: Selection
    private let crossover: Crossover
    private let mutate: Mutation

    private let p: ReproductionWay.Probabilities

    private var attemptLimit: Int { return 100 }

    public init(
        preferredCount: Int,
        evaluation: @escaping Evaluation,
        eliteCount: Int,
        selection: @escaping Selection,
        crossover: @escaping Crossover,
        mutation: @escaping Mutation,
        probabilities: ReproductionWay.Probabilities
    ) {
        // The extra space is for a possible extra individual produced during crossover
        self.items.reserveCapacity(preferredCount + 1)
        self.preferredCount = preferredCount
        self.evaluate = evaluation
        self.eliteCount = eliteCount
        self.select = selection
        self.crossover = crossover
        self.mutate = mutation
        self.p = probabilities
    }

    public func generateRandom<Grammar>(_ randomGenotypeFactory: RandomGenotypeFactory<Grammar>) throws {

        var hashSet = Set<Int>()

        while items.count < preferredCount {
            try attempt(limit: attemptLimit) { retry in
                let (genotype, hash) = try randomGenotypeFactory.make()

                if !hashSet.contains(hash) {
                    items.append(Item(genotype))
                    hashSet.insert(hash)
                } else {
                    try retry()
                }
            }
        }
    }

    public func generateNext() throws {

        var nextGeneration = selectElite(count: eliteCount)

        while nextGeneration.count < preferredCount {

            let baseGenotype = try select(items)

            switch ReproductionWay.sample(p) {
            case .crossover:
                let extraGenotype = try select(items)

                guard let (newGenotype1, newGenotype2) = try? crossover(baseGenotype, extraGenotype)
                else { continue }

                nextGeneration.append(Item(newGenotype1))
                nextGeneration.append(Item(newGenotype2))
            case .mutate:
                guard let newGenotype = try? mutate(baseGenotype)
                else { continue }

                nextGeneration.append(Item(newGenotype))
            case .copy:
                nextGeneration.append(Item(baseGenotype))
            }
        }

        items = nextGeneration
    }

    private func selectElite(count: Int) -> [Item] {
        return items.indices
            .sorted(by: { indexA, indexB in
                items[indexA].hasHigherScore(than: items[indexB])
            })
            .prefix(count)
            .map { index in items[index] }
    }

    public var best: Item? {
        return items.reduce(into: Item?.none, { result, item in
            if item.hasHigherScore(than: result) {
                result = item
            }
        })
    }

    public var averageScore: Double {
        return items.reduce(into: 0.0, { result, item in
                result += item.score ?? 0 }
            ) / Double(items.count)
    }

    public func evaluateAll() {
        items = items.map { item in
            item.score != nil ? item : item.scored(evaluate(item.genotype))
        }
    }

    public struct Item {

        public let genotype: AnyGenotype
        public let score: Double?

        public init(_ genotype: AnyGenotype, score: Double? = nil) {
            self.genotype = genotype
            self.score = score
        }

        public func scored(_ newScore: Double) -> Item {
            return Item(genotype, score: newScore)
        }

        public func hasHigherScore(than other: Item?) -> Bool {
            return Item.isHigherScore(score, than: other?.score)
        }

        public static func isHigherScore(_ a: Double?, than b: Double?) -> Bool {
            switch (a, b) {
            case (nil, _):
                return false
            case (.some, nil):
                return true
            case let (.some(a), .some(b)):
                return a > b
            }
        }
    }
}
