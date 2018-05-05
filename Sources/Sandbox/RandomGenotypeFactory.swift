public struct RandomGenotypeFactory<Grammar: SomeGrammar> {

    private let grammar: Grammar.Type

    public init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    public func make() throws -> AnyGenotype {
        let iterator = RandomIterator()
        _ = try grammar.generate(iterator)
        return Genotype(iterator.codons)
    }

    final class RandomIterator: GenotypeIterating {

        var codons = [Int]()

        func next<T>(tag: String, below upperBound: Int, _ body: (Int) throws -> T) throws -> T {
            let codon = rand(below: 100)
            codons.append(codon)
            return try body(codon % upperBound)
        }
    }
}
