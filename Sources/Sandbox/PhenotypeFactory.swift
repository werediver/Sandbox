struct PhenotypeFactory {

    private let grammar: Grammar.Type

    init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    func make(from genotype: Genotype) throws -> String {
        let iterator = genotype.makeIterator()
        let phenotype = try grammar.generate(iterator)
        return phenotype
    }
}
