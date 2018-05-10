public struct RandomGenotypeFactory<Grammar: SomeGrammar> {

    private let grammar: Grammar.Type
    private let codonsCountLimit: Int
    private let attemptsLimit = 100

    public init(grammar: Grammar.Type, limit: Int) {
        self.grammar = grammar
        self.codonsCountLimit = limit
    }

    public func make() throws -> (genotype: AnyGenotype, hash: Int) {
        return try attempt(limit: attemptsLimit) {
            let iterator = RandomIterator(limit: codonsCountLimit)
            _ = try grammar.generate(iterator)
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
