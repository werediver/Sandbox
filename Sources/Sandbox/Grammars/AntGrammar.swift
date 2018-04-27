enum AntGrammar: Grammar {

    enum Failure: Error {

        case invalidCodon
    }

    static func generate(_ rule: GenotypeIterating) throws -> String {
        return try prog(rule)
    }

    static func prog(_ rule: GenotypeIterating) throws -> String {

        // PROG → LINE
        //      / LINE PROG

        return try rule.next(below: 2) { codon in
            switch codon {
            case 0:
                return try line(rule)
            case 1:
                return try line(rule) + "\n" + prog(rule)
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func line(_ rule: GenotypeIterating) throws -> String {

        // LINE → COND / OP

        return try rule.next(below: 2) { codon in
            switch codon {
            case 0:
                return try cond(rule)
            case 1:
                return try op(rule)
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func cond(_ rule: GenotypeIterating) throws -> String {

        // COND → IF_FOOD_AHEAD(OP, ELSE: OP)

        return try rule.next(below: 1) { codon in
            switch codon {
            case 0:
                return try "if foodAhead() { \(op(rule)) } else { \(op(rule)) }"
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func op(_ rule: GenotypeIterating) throws -> String {

        // OP → TURN_LEFT / TURN_RIGHT / MOVE

        return try rule.next(below: 3) { codon in
            switch codon {
            case 0:
                return "turnLeft()"
            case 1:
                return "turnRight()"
            case 2:
                return "move()"
            default:
                throw Failure.invalidCodon
            }
        }
    }
}
