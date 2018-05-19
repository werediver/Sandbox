public final class Population {

    public typealias Evaluation = (AnyGenotype) -> Double
    public typealias Selection  = ([Item]) throws -> AnyGenotype
    public typealias Crossover  = (AnyGenotype, AnyGenotype) throws -> (AnyGenotype, AnyGenotype)
    public typealias Mutation   = (AnyGenotype) throws -> AnyGenotype

    public typealias Probabilities = (crossover: Double, mutation: Double)

    public typealias Item = (genotype: AnyGenotype, score: Double?)

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
                    let item = Item(genotype: genotype, score: nil)
                    items.append(item)
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

                nextGeneration.append((genotype3, nil))
                nextGeneration.append((genotype4, nil))
            } else {
                if urand() < p.mutation {
                    do {
                        genotype1 = try mutate(genotype1)
                    } catch {
                        continue
                    }
                }
                nextGeneration.append((genotype1, nil))
            }
        }
        items = nextGeneration
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

    func selectElite(count: Int) -> [Item] {
        return items.indices
            .sorted(by: { indexA, indexB in
                Population.hasHigherScore(items[indexA], than: items[indexB])
            })
            .prefix(count)
            .map { index in items[index] }
    }

    static func hasHigherScore(_ a: Item?, than b: Item?) -> Bool {
        return isHigherScore(a?.score, than: b?.score)
    }

    static func isHigherScore(_ a: Double?, than b: Double?) -> Bool {
        switch (a, b) {
        case (nil, _):
            return false
        case (.some, nil):
            return true
        case let (.some(a), .some(b)):
            return a > b
        }
    }

    public var best: Item? {
        return items.reduce(into: Item?.none, { result, item in
            if Population.hasHigherScore(item, than: result) {
                result = item
            }
        })
    }

    public var averageScore: Double {
        return items.reduce(into: 0.0, { result, item in
                result += item.score ?? 0 }
            ) / Double(items.count)
    }
}
