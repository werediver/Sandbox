protocol GenotypeIterating {

    func next() -> Int?
}

struct Genotype {

    let codons: [Int]

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

        func next() -> Int? {
            guard offset < genotype.codons.count
            else { return nil }

            let codon = genotype.codons[offset]
            offset += 1

            return codon
        }
    }
}
