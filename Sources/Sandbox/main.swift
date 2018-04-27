func mutate<Grammar: SomeGrammar>(genotype: Genotype, grammar: Grammar.Type) throws -> Genotype {
    let subtreeScanner = SubtreeScanner(genotype)
    _ = try grammar.generate(subtreeScanner)

    let targetSubtreeOffset = rand(below: genotype.codons.count)
    let targetSubtreeSize = subtreeScanner.subtreeSize[targetSubtreeOffset]

    let mutator = SubtreeMutator(genotype, subtree: targetSubtreeOffset, size: targetSubtreeSize)

    _ = try grammar.generate(mutator)

    return mutator.genotype
}

let grammar = Ant.Grammar.self

for _ in 0 ..< 10 {
    let genotype = try! RandomGenotypeFactory(grammar: grammar).make()
    let phenotypeFactory = PhenotypeFactory(grammar: grammar)
    let phenotype = try! phenotypeFactory.make(from: genotype)

    let mutated = try! mutate(genotype: genotype, grammar: grammar)
    let mutatedPhenotype = try! phenotypeFactory.make(from: mutated)

    print("Original:\n\(phenotype)")
    print("Mutated:\n\(mutatedPhenotype)")
}
