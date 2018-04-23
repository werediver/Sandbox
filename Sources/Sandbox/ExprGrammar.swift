struct ExprGrammar {

    static func generate(_ rule: GenotypeIterating) -> String { return expr(rule) }

    static func expr(_ rule: GenotypeIterating) -> String {

        // EXPR ← EXPR OP EXPR
        //      / VAR

        let result: String
        switch rule.next().map({ $0 % 2 }) {
        case 0?:
            result = expr(rule) + op(rule) + expr(rule)
        case 1?:
            result = variable(rule)
        default:
            result = "ERROR"
        }
        return result
    }

    static func op(_ rule: GenotypeIterating) -> String {

        // OP ← "+" / "-" / "*" / "/"

        let result: String
        switch rule.next().map({ $0 % 4 }) {
        case 0?:
            result = "+"
        case 1?:
            result = "-"
        case 2?:
            result = "*"
        case 3?:
            result = "/"
        default:
            result = "ERROR"
        }
        return result
    }

    static func variable(_ rule: GenotypeIterating) -> String {

        // VAR ← "x"

        let result: String
        switch rule.next().map({ $0 % 1 }) {
        case 0?:
            result = "x"
        default:
            result = "ERROR"
        }
        return result
    }
}
