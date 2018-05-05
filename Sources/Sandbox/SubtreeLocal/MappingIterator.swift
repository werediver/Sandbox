public final class MappingIterator: GenotypeIterating {

    private let genotype: AnyGenotype
    private var offset = 0
    private var offsetStack = [Int]()

    public private(set) var map: [(tag: String, subtreeSize: Int)]

    public init(_ genotype: AnyGenotype) {
        self.genotype = genotype
        self.map = .init(repeating: ("", 0), count: genotype.codons.count)
    }

    public func next<T>(tag: String, below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
        guard offset < genotype.codons.count
        else { throw Failure.overrun }

        offsetStack.append(offset)

        let codon = genotype.codons[offset]
        offset += 1

        let result = try body(codon % upperBound)

        let subtreeRootOffset = offsetStack.removeLast()
        let subtreeSize = offset - subtreeRootOffset
        map[subtreeRootOffset] = (tag, subtreeSize)

        return result
    }

    public enum Failure: Error {

        case overrun
    }
}
