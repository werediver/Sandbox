public final class Crossover<Grammar: SomeGrammar> {

    private let grammar: Grammar.Type

    public init(grammar: Grammar.Type) {
        self.grammar = grammar
    }

    public func apply(to genotype1: AnyGenotype, _ genotype2: AnyGenotype, attemptsLimit: Int = 3) throws -> (AnyGenotype, AnyGenotype) {
        let mappingIterator1 = MappingIterator(genotype1)
        _ = try grammar.generate(mappingIterator1)

        let mappingIterator2 = MappingIterator(genotype2)
        _ = try grammar.generate(mappingIterator2)

        let tags1 = Set(mappingIterator1.map.map { $0.tag })
        let tags2 = Set(mappingIterator2.map.map { $0.tag })
        let commonTags = tags1.intersection(tags2)

        guard let targetTag = pickRandom(from: commonTags)
        else { throw Failure.inconsistentGrammar }

        for _ in 0 ..< attemptsLimit {
            let targetOffsetCandidates1 = mappingIterator1.map.enumerated()
                .filter { $0.offset > 0 && $0.element.tag == targetTag }
                .map { $0.offset }
            let targetOffsetCandidates2 = mappingIterator2.map.enumerated()
                .filter { $0.offset > 0 && $0.element.tag == targetTag }
                .map { $0.offset }

            if let targetOffset1 = pickRandom(from: targetOffsetCandidates1),
               let targetOffset2 = pickRandom(from: targetOffsetCandidates2),
               (targetOffset1, targetOffset2) != (0, 0)
            {
                let fragment1 = (offset: targetOffset1, count: mappingIterator1.map[targetOffset1].subtreeSize)
                let fragment2 = (offset: targetOffset2, count: mappingIterator2.map[targetOffset2].subtreeSize)

                var genotype3 = genotype1
                genotype3.codons[fragment1.offset ..< fragment1.offset + fragment1.count] = genotype2.codons[fragment2.offset ..< fragment2.offset + fragment2.count]

                var genotype4 = genotype2
                genotype4.codons[fragment2.offset ..< fragment2.offset + fragment2.count] = genotype1.codons[fragment1.offset ..< fragment1.offset + fragment1.count]

                return (genotype3, genotype4)
            }
        }

        throw Failure.cannotPerformCrossover
    }

    private func pickRandom<C: Collection>(from items: C) -> C.Element? {
        guard items.count > 0
        else { return nil }

        let offset = rand(below: items.count)
        let index = items.index(items.startIndex, offsetBy: offset)

        return items[index]
    }

    enum Failure: Error {
        case cannotPerformCrossover
        case inconsistentGrammar
    }
}
