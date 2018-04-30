public struct PhenotypeFactory<Grammar: SomeGrammar> {

    private let grammar: Grammar.Type

    public init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    public func make(from genotype: AnyGenotype) throws -> Grammar.Result {
        let iterator = genotype.makeIterator()
        let phenotype = try grammar.generate(iterator)
        return phenotype
    }
}
