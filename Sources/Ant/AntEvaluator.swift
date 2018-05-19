public final class AntEvaluator {

    private let envFactory: AntEnvironmentFactory

    public init(_ envFactory: AntEnvironmentFactory) {
        self.envFactory = envFactory
    }

    public func evaluate(_ ant: AntBlock, onChange: AntEnvironment.OnChange? = nil) -> Double {
        let env = envFactory.make(onChange: onChange)
        let runner = AntRunner(ant, env)

        while env.stepCount < 600, env.foodLeft > 0 {
            runner.run()
        }

        return Double(env.antScore)
    }
}

public extension AntEvaluator {

    static var santaFeTrail: AntEvaluator {
        let field = try! AntFieldLoader.load(from: "Santa Fe Trail.txt", size: (32, 32))
        let envFactory = AntEnvironmentFactory(field: field)
        let evaluator = AntEvaluator(envFactory)

        return evaluator
    }

    static var losAltosHillsTrail: AntEvaluator {
        let field = try! AntFieldLoader.load(from: "Los Altos Hills Trail.txt", size: (100, 100))
        let envFactory = AntEnvironmentFactory(field: field)
        let evaluator = AntEvaluator(envFactory)

        return evaluator
    }
}
