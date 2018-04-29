final class AntRunner {

    private let ant: AntProg
    private let env: AntControlling

    init(_ ant: AntProg, _ env: AntControlling) {
        self.ant = ant
        self.env = env
    }

    func run() { ant.accept(self) }
}

extension AntRunner: AntBehaviorVisitor {

    func visit(_ prog: AntProg) {
        prog.line.accept(self)
        prog.prog?.accept(self)
    }

    func visit(_ line: AntLine) {
        switch line {
        case let .cond(cond):
            cond.accept(self)
        case let .op(op):
            op.accept(self)
        }
    }

    func visit(_ cond: AntCond) {
        if env.foodAhead() {
            cond.right.accept(self)
        } else {
            cond.wrong.accept(self)
        }
    }

    func visit(_ op: AntOp) {
        switch op {
        case .move:
            env.moveForward()
        case .left:
            env.turnLeft()
        case .right:
            env.turnRight()
        }
        env.report()
    }
}
