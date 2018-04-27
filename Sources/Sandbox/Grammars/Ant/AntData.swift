extension Ant {

    final class Prog: CustomStringConvertible {

        let line: Line
        let prog: Prog?

        init(_ line: Line, _ prog: Prog? = nil) {
            self.line = line
            self.prog = prog
        }

        var description: String {
            return "\(line)\n\(prog.map(String.init(describing:)) ?? "")"
        }
    }

    enum Line: CustomStringConvertible {

        case cond(Cond)
        case op(Op)

        var description: String {
            switch self {
            case let .cond(cond):
                return "\(cond)"
            case let .op(op):
                return "\(op)"
            }
        }
    }

    struct Cond: CustomStringConvertible {

        let right: Op
        let wrong: Op

        var description: String {
            return "if food_ahead { \(right) } else { \(wrong) }"
        }
    }

    enum Op {

        case left
        case right
        case move
    }
}
