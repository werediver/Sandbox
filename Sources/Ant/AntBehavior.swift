protocol AntBehavior {

    func accept(_ visitor: AntBehaviorVisitor)
}

protocol AntBehaviorVisitor {

    func visit(_ block: AntBlock)
    func visit(_ statement: AntStatement)
    func visit(_ cond: AntCond)
    func visit(_ op: AntOp)
}

public final class AntBlock: AntBehavior, CustomStringConvertible {

    let statement: AntStatement
    let more: AntBlock?

    init(statement: AntStatement, more: AntBlock?) {
        self.statement = statement
        self.more = more
    }

    static func seq(_ statements: AntStatement...) -> AntBlock {
        assert(!statements.isEmpty)

        var rest = statements
        var block = AntBlock(statement: rest.removeLast(), more: nil)
        while !rest.isEmpty {
            let last = rest.removeLast()
            block = AntBlock(statement: last, more: block)
        }
        return block
    }

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }

    public var description: String {
        return "\(statement)\n\(more.map(String.init(describing:)) ?? "")"
    }
}

public enum AntStatement: AntBehavior, CustomStringConvertible {

    case cond(AntCond)
    case op(AntOp)

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }

    public var description: String {
        switch self {
        case let .cond(cond):
            return "\(cond)"
        case let .op(op):
            return "\(op)"
        }
    }
}

public struct AntCond: AntBehavior, CustomStringConvertible {

    let right: AntBlock
    let wrong: AntBlock

    init(right: AntBlock, wrong: AntBlock) {
        self.right = right
        self.wrong = wrong
    }

    init(right: AntOp, wrong: AntOp) {
        self.right = AntBlock(statement: .op(right), more: nil)
        self.wrong = AntBlock(statement: .op(wrong), more: nil)
    }

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }

    public var description: String {
        return "if food_ahead {\n\(String(describing: right).indented())} else {\n\(String(describing: wrong).indented())}"
    }
}

public enum AntOp: AntBehavior {

    case left
    case right
    case move

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }
}
