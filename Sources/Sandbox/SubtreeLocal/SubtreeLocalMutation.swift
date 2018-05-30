public final class SubtreeLocalMutation {

    typealias GenotypeScanner = (GenotypeIterating) throws -> Void

    private let scan: GenotypeScanner
    private let codonsCountLimit: Int
    private let attemptsLimit = 100

    public init<Grammar: SomeGrammar>(grammar: Grammar.Type, limit: Int) {
        self.scan = { _ = try grammar.generate($0) }
        self.codonsCountLimit = limit
    }

    public func apply(to genotype: AnyGenotype) throws -> AnyGenotype {
        let mappingIterator = MappingIterator(genotype)
        try scan(mappingIterator)

        return try attempt(limit: attemptsLimit) {
            let targetSubtreeOffset = rand(below: genotype.codons.count)
            let targetSubtreeSize = mappingIterator.map[targetSubtreeOffset].subtreeSize

            let mutatingIterator = MutatingIterator(genotype, subtree: targetSubtreeOffset, size: targetSubtreeSize, limit: codonsCountLimit)
            try scan(mutatingIterator)

            return mutatingIterator.genotype
        }
    }
}

private final class MutatingIterator: GenotypeIterating {

    private(set) var genotype: AnyGenotype

    private let codonsCountLimit: Int
    private let targetSubtree: (offset: Int, size: Int)

    private var offset = 0
    private var offsetStack = [Int]()

    public init(_ genotype: AnyGenotype, subtree targetSubtreeOffset: Int, size targetSubtreeSize: Int, limit: Int) {
        self.genotype = genotype
        self.codonsCountLimit = limit
        self.targetSubtree = (targetSubtreeOffset, targetSubtreeSize)
    }

    public func next<T>(tag: String, below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
        guard genotype.codons.count <= codonsCountLimit
        else { throw MutationFailure.codonsCountLimitExceeded }

        if offset == targetSubtree.offset {
            genotype.codons[offset] = rand()
        }
        if offsetStack.contains(targetSubtree.offset),
           offset - targetSubtree.offset >= targetSubtree.size
        {
            genotype.codons.insert(rand(), at: offset)
        }

        guard offset < genotype.codons.count
        else { throw MutationFailure.overrun }

        offsetStack.append(offset)

        let codon = genotype.codons[offset]
        offset += 1

        let result = try body(codon % upperBound)

        let subtreeRootOffset = offsetStack.removeLast()
        if subtreeRootOffset == targetSubtree.offset {
            let newTargetSubtreeSize = offset - subtreeRootOffset
            if newTargetSubtreeSize < targetSubtree.size {
                genotype.codons.removeSubrange(offset ..< targetSubtree.offset + targetSubtree.size)
            }
        }

        return result
    }
}

public enum MutationFailure: Error {

    case overrun
    case codonsCountLimitExceeded
}
