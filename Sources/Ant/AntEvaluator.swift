public final class AntEvaluator {

    private let envFactory: AntEnvironmentFactory

    public init(_ envFactory: AntEnvironmentFactory) {
        self.envFactory = envFactory
    }

    public func evaluate(_ ant: AntProg, onChange: AntEnvironment.OnChange? = nil) -> Double {
        let env = envFactory.make(onChange: onChange)
        let runner = AntRunner(ant, env)

        var count = 600
        while count > 0, env.foodLeft > 0 {
            runner.run()
            count -= 1
        }

        let score = Double(env.antScore) / Double(env.stepCount)

        return score
    }
}

public extension AntEvaluator {

    static var santaFeAntTrail: AntEvaluator {
        let field = try! AntFieldLoader.load(from: "Santa Fe ant trail.txt")
        let envFactory = AntEnvironmentFactory(field: field)
        let evaluator = AntEvaluator(envFactory)

        return evaluator
    }
}
