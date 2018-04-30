import protocol Sandbox.SomeGrammar
import protocol Sandbox.GenotypeIterating

public enum AntGrammar: SomeGrammar {

    enum Failure: Error {

        case invalidCodon
    }

    public static func generate(_ rule: GenotypeIterating) throws -> AntProg {
        return try prog(rule)
    }

    static func prog(_ rule: GenotypeIterating) throws -> AntProg {

        // PROG → LINE
        //      / LINE PROG

        return try rule.next(below: 2) { codon in
            switch codon {
            case 0:
                return try AntProg(line(rule))
            case 1:
                return try AntProg(line(rule), prog(rule))
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func line(_ rule: GenotypeIterating) throws -> AntLine {

        // LINE → COND / OP

        return try rule.next(below: 2) { codon in
            switch codon {
            case 0:
                return try .cond(cond(rule))
            case 1:
                return try .op(op(rule))
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func cond(_ rule: GenotypeIterating) throws -> AntCond {

        // COND → IF_FOOD_AHEAD(OP, ELSE: OP)

        return try rule.next(below: 1) { codon in
            switch codon {
            case 0:
                return try AntCond(right: op(rule), wrong: op(rule))
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func op(_ rule: GenotypeIterating) throws -> AntOp {

        // OP → TURN_LEFT / TURN_RIGHT / MOVE

        return try rule.next(below: 3) { codon in
            switch codon {
            case 0:
                return .left
            case 1:
                return .right
            case 2:
                return .move
            default:
                throw Failure.invalidCodon
            }
        }
    }
}
