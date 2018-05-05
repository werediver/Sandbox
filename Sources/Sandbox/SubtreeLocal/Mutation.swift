public final class Mutation<Grammar: SomeGrammar> {

    private let grammar: Grammar.Type

    public init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    public func apply(to genotype: AnyGenotype) throws -> AnyGenotype {
        let mappingIterator = MappingIterator(genotype)
        _ = try grammar.generate(mappingIterator)

        let targetSubtreeOffset = rand(below: genotype.codons.count)
        let targetSubtreeSize = mappingIterator.map[targetSubtreeOffset].subtreeSize

        let mutatingIterator = MutatingIterator(genotype, subtree: targetSubtreeOffset, size: targetSubtreeSize)
        _ = try grammar.generate(mutatingIterator)

        return mutatingIterator.genotype
    }
}

private final class MutatingIterator: GenotypeIterating {

    private(set) var genotype: AnyGenotype

    private let targetSubtree: (offset: Int, size: Int)

    private var offset = 0
    private var offsetStack = [Int]()

    public init(_ genotype: AnyGenotype, subtree targetSubtreeOffset: Int, size targetSubtreeSize: Int) {
        self.genotype = genotype
        self.targetSubtree = (targetSubtreeOffset, targetSubtreeSize)
    }

    public func next<T>(tag: String, below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
        if offset == targetSubtree.offset {
            genotype.codons[offset] = rand()
        }
        if offsetStack.contains(targetSubtree.offset),
           offset - targetSubtree.offset >= targetSubtree.size
        {
            genotype.codons.insert(rand(), at: offset)
        }

        guard offset < genotype.codons.count
        else { throw Failure.overrun }

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

    public enum Failure: Error {

        case overrun
    }
}
