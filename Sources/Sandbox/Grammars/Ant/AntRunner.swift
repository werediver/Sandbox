final class AntRunner {

    private let plan: [AntLine]
    private let env: AntControlling

    init(_ ant: AntProg, _ env: AntControlling) {
        self.plan = AntRunner.plan(ant)
        self.env = env
    }

    func run() {
        plan.forEach { line in
            switch line {
            case let .cond(cond):
                if env.foodAhead() {
                    execute(cond.right)
                } else {
                    execute(cond.wrong)
                }
            case let .op(op):
                execute(op)
            }
            env.report()
        }
    }

    private func execute(_ op: AntOp) {
        switch op {
        case .move:
            env.moveForward()
        case .left:
            env.turnLeft()
        case .right:
            env.turnRight()
        }
    }

    private static func plan(_ prog: AntProg) -> [AntLine] {

        final class LineCollector: AntBehaviorVisitor {

            private(set) var lines = [AntLine]()

            func visit(_ prog: AntProg) {
                prog.line.accept(self)
                prog.prog?.accept(self)
            }

            func visit(_ line: AntLine) {
                lines.append(line)
            }

            func visit(_ cond: AntCond) {}

            func visit(_ op: AntOp) {}
        }

        let lineCollector = LineCollector()

        prog.accept(lineCollector)

        return lineCollector.lines
    }
}
