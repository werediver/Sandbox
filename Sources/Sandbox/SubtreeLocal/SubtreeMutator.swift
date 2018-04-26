final class SubtreeMutator: GenotypeIterating {

    private(set) var genotype: Genotype
    private var offset = 0
    private var offsetStack = [Int]()

    private let targetSubtreeOffset: Int
    private let targetSubtreeSize: Int

    init(_ genotype: Genotype, subtree targetSubtreeOffset: Int, size targetSubtreeSize: Int) {
        self.genotype = genotype
        self.targetSubtreeOffset = targetSubtreeOffset
        self.targetSubtreeSize = targetSubtreeSize
        print("Target subtree offset: \(targetSubtreeOffset)")
        print("Target subtree size: \(targetSubtreeSize)")
    }

    func next<T>(_ body: (Int) throws -> T) throws -> T {
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

        let result = try body(codon)

        let subtreeRootOffset = offsetStack.removeLast()
        if subtreeRootOffset == targetSubtreeOffset {
            let newTargetSubtreeSize = offset - subtreeRootOffset
            print("New target subtree size: \(newTargetSubtreeSize)")
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
