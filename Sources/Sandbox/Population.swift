public final class Population {

    public typealias Evaluation = (AnyGenotype) -> Double
    public typealias Selection  = ([Item]) throws -> AnyGenotype
    public typealias Crossover  = (AnyGenotype, AnyGenotype) throws -> (AnyGenotype, AnyGenotype)
    public typealias Mutation   = (AnyGenotype) throws -> AnyGenotype

    public typealias Probabilities = (crossover: Double, mutation: Double)

    public var items = [Item]()
    public let preferredCount: Int

    private let eliteCount: Int
    
    private let evaluate: Evaluation
    private let select: Selection
    private let crossover: Crossover
    private let mutate: Mutation

    private let p: Probabilities

    private var attemptLimit: Int { return 100 }

    public init(preferredCount: Int, eliteCount: Int, evaluation: @escaping Evaluation, selection: @escaping Selection, crossover: @escaping Crossover, mutation: @escaping Mutation, probabilities: Probabilities) {
        // The extra space is for a possible extra individual produced during crossover
        self.items.reserveCapacity(preferredCount + 1)
        self.preferredCount = preferredCount
        self.eliteCount = eliteCount
        self.evaluate = evaluation
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
        // Preserve elite
        var nextGeneration = selectElite(count: eliteCount)
        // Fill up to the required size
        while nextGeneration.count < preferredCount {
            // Select the base individual
            var genotype1 = try select(items)
            // Decide what operators to apply:
            // - crossover (with an extra individual)
            // - mutation
            // - copy
            if urand() < p.crossover {
                let genotype2 = try select(items)

                guard let (genotype3, genotype4) = try? crossover(genotype1, genotype2)
                else { continue }

                nextGeneration.append(Item(genotype3))
                nextGeneration.append(Item(genotype4))
            } else {
                if urand() < p.mutation {
                    do {
                        genotype1 = try mutate(genotype1)
                    } catch {
                        continue
                    }
                }
                nextGeneration.append(Item(genotype1))
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
