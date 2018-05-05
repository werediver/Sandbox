enum ExprGrammar: SomeGrammar {

    public enum Failure: Error {

        case invalidCodon
    }

    static func generate(_ rule: GenotypeIterating) throws -> String { return try expr(rule) }

    static func expr(_ rule: GenotypeIterating) throws -> String {

        // EXPR ← EXPR OP EXPR
        //      / VAR

        return try rule.next(tag: "prog", below: 2) { codon in
            switch codon {
            case 0:
                return try "(" + expr(rule) + op(rule) + expr(rule) + ")"
            case 1:
                return try variable(rule)
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func op(_ rule: GenotypeIterating) throws -> String {

        // OP ← "+" / "-" / "*" / "/"

        return try rule.next(tag: "op", below: 4) { codon in
            switch codon {
            case 0:
                return "+"
            case 1:
                return "-"
            case 2:
                return "*"
            case 3:
                return "/"
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func variable(_ rule: GenotypeIterating) throws -> String {

        // VAR ← "x"

        return try rule.next(tag: "variable", below: 1) { codon in
            switch codon % 1 {
            case 0:
                return "x"
            default:
                throw Failure.invalidCodon
            }
        }
    }
}
