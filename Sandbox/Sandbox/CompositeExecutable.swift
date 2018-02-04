public struct CompositeExecutable: Executable {

    public enum Failure: Error, CustomStringConvertible {
        case degenerateCompositeExecutable
        case typeMismatch(Executable, Executable)

        public var description: String {
            switch self {
            case .degenerateCompositeExecutable:
                return "Composite executable should contain at least two child executables"
            case let .typeMismatch(left, right):
                return "Executables type mismatch: \(left) cannot be composed with \(right)"
            }
        }
    }

    public let types: Types
    public let cost: Int

    public let children: [Executable]

    public init(_ children: [Executable]) throws {
        guard
            children.count >= 2,
            let first = children.first,
            let last  = children.last
        else { throw Failure.degenerateCompositeExecutable }

        for (a, b) in zip(children, children.dropFirst()) {
            guard a.types.output.isSubtype(of: b.types.input)
            else { throw Failure.typeMismatch(a, b) }
        }

        self.types = (first.types.input, last.types.output)
        self.cost = children.reduce(into: 0) { cost, executable in cost += executable.cost }
        self.children = children
    }

    public func execute(in context: Context, with input: Instance) throws -> Instance {
        var result = input
        for child in children {
            result = try child.execute(in: context, with: result)
        }
        return result
    }
}
