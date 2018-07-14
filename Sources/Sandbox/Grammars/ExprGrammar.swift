enum ExprGrammar: SomeGrammar {

    public enum Failure: Error {

        case invalidCodon
    }

    static func generate(_ rule: GenotypeIterating) throws -> String { return try expr(rule) }

    static func expr(_ rule: GenotypeIterating) throws -> String {

        // EXPR ← EXPR OP EXPR
        //      / VAR

        return try rule.next(
            { try "(" + expr(rule) + op(rule) + expr(rule) + ")" },
            { try variable(rule) }
        )
    }

    static func op(_ rule: GenotypeIterating) throws -> String {

        // OP ← "+" / "-" / "*" / "/"

        return try rule.next(
            { "+" },
            { "-" },
            { "*" },
            { "/" }
        )
    }

    static func variable(_ rule: GenotypeIterating) throws -> String {

        // VAR ← "x"

        return try rule.next(
            { "x" }
        )
    }
}
