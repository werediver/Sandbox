public final class SubtreeMutator: GenotypeIterating {

    public private(set) var genotype: AnyGenotype
    private var offset = 0
    private var offsetStack = [Int]()

    private let targetSubtreeOffset: Int
    private let targetSubtreeSize: Int

    public init(_ genotype: AnyGenotype, subtree targetSubtreeOffset: Int, size targetSubtreeSize: Int) {
        self.genotype = genotype
        self.targetSubtreeOffset = targetSubtreeOffset
        self.targetSubtreeSize = targetSubtreeSize
    }

    public func next<T>(below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
        if offset == targetSubtreeOffset {
            genotype.codons[offset] = rand()
        }
        if offsetStack.contains(targetSubtreeOffset),
           offset - targetSubtreeOffset >= targetSubtreeSize
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
        if subtreeRootOffset == targetSubtreeOffset {
            let newTargetSubtreeSize = offset - subtreeRootOffset
            if newTargetSubtreeSize < targetSubtreeSize {
                genotype.codons.removeSubrange(offset ..< targetSubtreeOffset + targetSubtreeSize)
            }
        }

        return result
    }

    enum Failure: Error {

        case overrun
    }
}
