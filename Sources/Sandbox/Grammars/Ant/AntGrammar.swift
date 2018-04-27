enum Ant {

    enum Grammar: SomeGrammar {

        enum Failure: Error {

            case invalidCodon
        }

        static func generate(_ rule: GenotypeIterating) throws -> Prog {
            return try prog(rule)
        }

        static func prog(_ rule: GenotypeIterating) throws -> Prog {

            // PROG → LINE
            //      / LINE PROG

            return try rule.next(below: 2) { codon in
                switch codon {
                case 0:
                    return try Prog(line(rule))
                case 1:
                    return try Prog(line(rule), prog(rule))
                default:
                    throw Failure.invalidCodon
                }
            }
        }

        static func line(_ rule: GenotypeIterating) throws -> Line {

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

        static func cond(_ rule: GenotypeIterating) throws -> Cond {

            // COND → IF_FOOD_AHEAD(OP, ELSE: OP)

            return try rule.next(below: 1) { codon in
                switch codon {
                case 0:
                    return try Cond(right: op(rule), wrong: op(rule))
                default:
                    throw Failure.invalidCodon
                }
            }
        }

        static func op(_ rule: GenotypeIterating) throws -> Op {

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
}
