struct RandomGenotypeFactory {

    private let grammar: Grammar.Type

    init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    func make() throws -> Genotype {
        let iterator = RandomIterator()
        _ = try grammar.generate(iterator)
        return Genotype(iterator.codons)
    }

    final class RandomIterator: GenotypeIterating {

        var codons = [Int]()

        func next<T>(below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
            let codon = rand(below: 128)
            codons.append(codon)
            return try body(codon % upperBound)
        }
    }
}
