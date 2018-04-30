protocol AntBehavior {

    func accept(_ visitor: AntBehaviorVisitor)
}

protocol AntBehaviorVisitor {

    func visit(_ prog: AntProg)
    func visit(_ line: AntLine)
    func visit(_ cond: AntCond)
    func visit(_ op: AntOp)
}

public final class AntProg: AntBehavior, CustomStringConvertible {

    let line: AntLine
    let prog: AntProg?

    init(_ line: AntLine, _ prog: AntProg? = nil) {
        self.line = line
        self.prog = prog
    }

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }

    public var description: String {
        return "\(line)\n\(prog.map(String.init(describing:)) ?? "")"
    }
}

public enum AntLine: AntBehavior, CustomStringConvertible {

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

    let right: AntOp
    let wrong: AntOp

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }

    public var description: String {
        return "if food_ahead { \(right) } else { \(wrong) }"
    }
}

public enum AntOp: AntBehavior {

    case left
    case right
    case move

    func accept(_ visitor: AntBehaviorVisitor) { visitor.visit(self) }
}
