struct RandomGenotypeFactory {

    func make() -> Genotype {
        let iterator = RandomIterator()
        _ = try? ExprGrammar.generate(iterator)
        return Genotype(iterator.codons)
    }

    final class RandomIterator: GenotypeIterating {

        var codons = [Int]()

        func next<T>(_ body: (Int) throws -> T) throws -> T {
            let codon = rand()
            codons.append(codon)
            return try body(codon)
        }
    }
}

struct PhenotypeFactory {

    func make(from genotype: Genotype) -> String? {
        let iterator = genotype.makeIterator()
        let phenotype = try? ExprGrammar.generate(iterator)
        return phenotype
    }
}

func mutate(genotype: Genotype) throws -> Genotype {
    let subtreeScanner = SubtreeScanner(genotype)
    _ = try ExprGrammar.generate(subtreeScanner)
    print("Genotype:     \(genotype.codons)")
    print("Subtree size: \(subtreeScanner.subtreeSize)")

    let targetSubtreeOffset = rand(below: genotype.codons.count)
    let targetSubtreeSize = subtreeScanner.subtreeSize[targetSubtreeOffset]

    let mutator = SubtreeMutator(genotype, subtree: targetSubtreeOffset, size: targetSubtreeSize)

    _ = try ExprGrammar.generate(mutator)

    return mutator.genotype
}

for _ in 0 ..< 10 {
    let genotype = RandomGenotypeFactory().make()
    let phenotype = PhenotypeFactory().make(from: genotype)
    print(" > " + (phenotype ?? "nil"))
    let mutated = try! mutate(genotype: genotype)
    let mutatedPhenotype = PhenotypeFactory().make(from: mutated)
    print("x> " + (mutatedPhenotype ?? "nil"))
}
