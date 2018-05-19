public enum ReproductionWay {

    public typealias Probabilities = (crossover: Double, mutation: Double)

    case crossover
    case mutate
    case copy

    public static func sample(_ p: Probabilities) -> ReproductionWay {
        assert(p.crossover + p.mutation <= 1)

        switch urand() {
        case 0 ..< p.crossover:
            return .crossover
        case p.crossover ..< p.crossover + p.mutation:
            return .mutate
        default:
            return .copy
        }
    }
}
