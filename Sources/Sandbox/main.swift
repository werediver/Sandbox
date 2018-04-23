struct RandomGenotypeFactory {

    func make() -> Genotype {
        let iterator = RandomIterator()
        _ = ExprGrammar.generate(iterator)
        return Genotype(iterator.codons)
    }

    final class RandomIterator: GenotypeIterating {

        var codons = [Int]()

        func next() -> Int? {
            let codon = rand()
            codons.append(codon)
            return codon
        }
    }
}

struct PhenotypeFactory {

    func make(from genotype: Genotype) -> String {
        let iterator = genotype.makeIterator()
        let phenotype = ExprGrammar.generate(iterator)
        return phenotype
    }
}

for _ in 0 ..< 10 {
    let genome = RandomGenotypeFactory().make()
    let phenotype = PhenotypeFactory().make(from: genome)
    print("> " + phenotype)
}
