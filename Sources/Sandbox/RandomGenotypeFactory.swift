public struct RandomGenotypeFactory {

    private typealias Generate = (GenotypeIterating) throws -> Void

    private let generate: Generate
    private let codonsCountLimit: Int
    private let attemptsLimit = 100

    public init<Grammar: SomeGrammar>(grammar: Grammar.Type, limit: Int) {
        self.generate = { _ = try grammar.generate($0) }
        self.codonsCountLimit = limit
    }

    public func make() throws -> (genotype: AnyGenotype, hash: Int) {
        return try attempt(limit: attemptsLimit) {
            let iterator = RandomIterator(limit: codonsCountLimit)
            try generate(iterator)
            return (Genotype(iterator.codons), iterator.combinedHash)
        }
    }

    final class RandomIterator: GenotypeIterating {

        var codons = [Int]()
        var combinedHash: Int { return hashCombiner.combinedHash }

        private var hashCombiner = HashCombiner()
        private let codonsCountLimit: Int

        init(limit: Int) {
            self.codonsCountLimit = limit
        }

        func next<T>(tag: String, below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
            guard codons.count <= codonsCountLimit
            else { throw Failure.codonsCountLimitExceeded }

            let codon = rand(below: 100)
            codons.append(codon)
            let rule = codon % upperBound
            hashCombiner.combine(rule)
            return try body(rule)
        }
    }

    enum Failure: Error {
        case codonsCountLimitExceeded
    }
}
