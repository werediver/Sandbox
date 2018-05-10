public protocol AntControllable {

    func moveForward()
    func turnLeft()
    func turnRight()

    func foodAhead() -> Bool
}

public struct AntRunner {

    private let ant: AntBlock
    private let env: AntControllable

    public init(_ ant: AntBlock, _ env: AntControllable) {
        self.ant = ant
        self.env = env
    }

    public func run() { ant.accept(self) }
}

extension AntRunner: AntBehaviorVisitor {

    func visit(_ block: AntBlock) {
        block.statement.accept(self)
        block.more?.accept(self)
    }

    func visit(_ statement: AntStatement) {
        switch statement {
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
    }
}
