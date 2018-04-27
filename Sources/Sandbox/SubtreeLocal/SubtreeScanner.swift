final class SubtreeScanner: GenotypeIterating {

    private let genotype: Genotype
    private var offset = 0
    private var offsetStack = [Int]()

    private(set) var subtreeSize: [Int]

    init(_ genotype: Genotype) {
        self.genotype = genotype
        self.subtreeSize = [Int](repeating: 0, count: genotype.codons.count)
    }

    func next<T>(below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
        guard offset < genotype.codons.count
        else { throw Failure.overrun }

        offsetStack.append(offset)

        let codon = genotype.codons[offset]
        offset += 1

        let result = try body(codon % upperBound)

        let subtreeRootOffset = offsetStack.removeLast()
        subtreeSize[subtreeRootOffset] = offset - subtreeRootOffset

        return result
    }

    enum Failure: Error {

        case overrun
    }
}
