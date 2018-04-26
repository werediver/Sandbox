struct ExprGrammar {

    enum Failure: Error {

        case invalidGenotype
    }

    static func generate(_ rule: GenotypeIterating) throws -> String { return try expr(rule) }

    static func expr(_ rule: GenotypeIterating) throws -> String {

        // EXPR ← EXPR OP EXPR
        //      / VAR

        return try rule.next { codon in
            switch codon % 2 {
            case 0:
                return try expr(rule) + op(rule) + expr(rule)
            case 1:
                return try variable(rule)
            default:
                throw Failure.invalidGenotype
            }
        }
    }

    static func op(_ rule: GenotypeIterating) throws -> String {

        // OP ← "+" / "-" / "*" / "/"

        return try rule.next { codon in
            switch codon % 4 {
            case 0:
                return "+"
            case 1:
                return "-"
            case 2:
                return "*"
            case 3:
                return "/"
            default:
                throw Failure.invalidGenotype
            }
        }
    }

    static func variable(_ rule: GenotypeIterating) throws -> String {

        // VAR ← "x"

        return try rule.next { codon in
            switch codon % 1 {
            case 0:
                return "x"
            default:
                throw Failure.invalidGenotype
            }
        }
    }
}
