public protocol Context {

    func execute(_ executable: Executable)
}

public protocol Executable {

    typealias Types = (input: TypeRepresenting, output: TypeRepresenting)

    var name: String { get }
    var types: Types { get }
    var cost: Int { get }

    func execute(in context: Context, with input: Instance) throws -> Instance
}

public extension Executable {

    var name: String { return "\(type(of: self))" }

    func composed(with executables: [Executable]) throws -> CompositeExecutable {
        return try CompositeExecutable([self] + executables)
    }
}
