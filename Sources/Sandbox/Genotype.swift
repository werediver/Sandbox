public protocol AnyGenotype {

    var codons: [Int] { get set }

    func makeIterator() -> GenotypeIterating
}

public protocol GenotypeIterating {

    func next<T>(below upperBound: Int, _ body: (Int) throws -> T) throws -> T
}

struct Genotype: AnyGenotype {

    var codons: [Int]

    init(_ codons: [Int]) {
        self.codons = codons
    }

    func makeIterator() -> GenotypeIterating { return Iterator(self) }

    final class Iterator: GenotypeIterating {

        private let genotype: Genotype
        private var offset = 0

        init(_ genotype: Genotype) {
            self.genotype = genotype
        }

        func next<T>(below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
            guard offset < genotype.codons.count
            else { throw Failure.overrun }

            let codon = genotype.codons[offset]
            offset += 1

            return try body(codon % upperBound)
        }
    }

    enum Failure: Error {

        case overrun
    }
}
