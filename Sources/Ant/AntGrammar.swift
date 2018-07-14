import protocol Sandbox.SomeGrammar
import protocol Sandbox.GenotypeIterating

public enum AntGrammar: SomeGrammar {

    public enum Failure: Error {

        case invalidCodon
    }

    public static func generate(_ rule: GenotypeIterating) throws -> AntBlock {

        //   START → BLOCK
        // x START → COND

        return try block(rule)
        //return try AntBlock.seq(.cond(cond(rule)))
    }

    static func block(_ rule: GenotypeIterating) throws -> AntBlock {

        // BLOCK → STMT
        //       / STMT BLOCK

        return try rule.next(
            { try AntBlock(statement: statement(rule), more: nil) },
            { try AntBlock(statement: statement(rule), more: block(rule)) }
        )
    }

    static func statement(_ rule: GenotypeIterating) throws -> AntStatement {

        // STMT → COND
        //      / OP

        return try rule.next(
            { try .cond(cond(rule)) },
            { try .op(op(rule)) }
        )
    }

    static func cond(_ rule: GenotypeIterating) throws -> AntCond {

        //   COND → (RIGHT: BLOCK, WRONG: BLOCK)
        // x COND → (RIGHT: MOVE, WRONG: BLOCK)

        return try AntCond(right: block(rule), wrong: block(rule))
        //return try AntCond(right: AntBlock.seq(.op(.move)), wrong: block(rule))
    }

    static func op(_ rule: GenotypeIterating) throws -> AntOp {

        // OP → TURN_LEFT / TURN_RIGHT / MOVE

        return try rule.next(
            { .left },
            { .right },
            { .move }
        )
    }

    public static var referenceAnt: AntBlock {
        return AntBlock.seq(
                .cond(AntCond(
                    right: AntBlock.seq(
                        .op(.move)
                    ),
                    wrong: AntBlock.seq(
                        .op(.right),
                        .cond(AntCond(
                            right: AntBlock.seq(
                                .op(.move)
                            ),
                            wrong: AntBlock.seq(
                                .op(.right),
                                .op(.right),
                                .cond(AntCond(
                                    right: AntBlock.seq(
                                        .op(.move)
                                    ),
                                    wrong: AntBlock.seq(
                                        .op(.right),
                                        .op(.move)
                                    )
                                ))
                            )
                        ))
                    )
                ))
            )
    }
}
