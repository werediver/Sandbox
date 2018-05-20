public enum ReproductionWay {

    case generate
    case crossover
    case mutate
    case copy
}

public struct ReproductionProfile {

    public let generate: Double
    public let crossover: Double
    public let mutate: Double

    public init(generate: Double, crossover: Double, mutate: Double) {

        assert(generate + crossover + mutate <= 1)

        self.generate = generate
        self.crossover = crossover
        self.mutate = mutate
    }

    public func cumulative(_ way: ReproductionWay) -> Double {

        switch way {
        case .generate:
            return generate
        case .crossover:
            return generate + crossover
        case .mutate:
            return generate + crossover + mutate
        case .copy:
            return max(1, cumulative(.mutate))
        }
    }
}

public struct ReproductionShaper {

    public let profile: ReproductionProfile

    public init(profile: ReproductionProfile) {

        self.profile = profile
    }

    public func sample() -> ReproductionWay {

        switch urand() {
        case 0 ..< profile.cumulative(.generate):
            return .generate
        case profile.cumulative(.generate) ..< profile.cumulative(.crossover):
            return .crossover
        case profile.cumulative(.crossover) ..< profile.cumulative(.mutate):
            return .mutate
        default:
            return .copy
        }
    }
}
