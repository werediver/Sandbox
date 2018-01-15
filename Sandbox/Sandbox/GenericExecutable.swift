public struct GenericExecutable: Executable {

    public typealias Body = (Context, Instance) throws -> Instance

    public let name: String
    public let types: Types
    public let cost: Int

    private let body: Body

    public init(name: String? = nil, types: Types, cost: Int = 1, _ body: @escaping Body) {
        self.name = name ?? "\(GenericExecutable.self)"
        self.types = types
        self.cost = cost
        self.body = body
    }

    public func execute(in context: Context, with input: Instance) throws -> Instance {
        guard types.input.isType(of: input)
        else { throw Failure.typeMismatch(actual: input.type, expected: types.input) }

        let output = try body(context, input)

        guard types.output.isType(of: output)
        else { throw Failure.typeMismatch(actual: output.type, expected: types.output) }

        return output
    }
}
