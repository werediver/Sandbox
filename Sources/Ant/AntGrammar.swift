import protocol Sandbox.SomeGrammar
import protocol Sandbox.GenotypeIterating

public enum AntGrammar: SomeGrammar {

    public enum Failure: Error {

        case invalidCodon
    }

    public static func generate(_ rule: GenotypeIterating) throws -> AntBlock {
        return try block(rule)
    }

    static func block(_ rule: GenotypeIterating) throws -> AntBlock {

        // BLOCK → STMT
        //       / STMT BLOCK

        return try rule.next(tag: "lines", below: 2) { codon in
            switch codon {
            case 0:
                return try AntBlock(statement: statement(rule), more: nil)
            case 1:
                return try AntBlock(statement: statement(rule), more: block(rule))
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func statement(_ rule: GenotypeIterating) throws -> AntStatement {

        // STMT → OP
        //      / IF_FOOD_AHEAD(BLOCK, ELSE: BLOCK)

        return try rule.next(tag: "line", below: 2) { codon in
            switch codon {
            case 0:
                return try .op(op(rule))
            case 1:
                return try .cond(AntCond(right: block(rule), wrong: block(rule)))
            default:
                throw Failure.invalidCodon
            }
        }
    }

    static func op(_ rule: GenotypeIterating) throws -> AntOp {

        // OP → TURN_LEFT / TURN_RIGHT / MOVE

        return try rule.next(tag: "op", below: 3) { codon in
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
