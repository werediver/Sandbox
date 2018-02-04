public protocol TypeRepresenting: class {

    var name: String { get }
    var parameters: [TypeParameter] { get }

    func isType(of some: Instance) -> Bool
    func isSubtype(of other: TypeRepresenting) -> Bool

    //func makeInstance() -> Instance
}

public extension TypeRepresenting {

    func isEqual(to other: TypeRepresenting) -> Bool {
        return name == other.name
            && parameters.count == other.parameters.count
            && !zip(parameters, other.parameters).contains(where: { !$0.isEqual(to: $1) })
    }

    func refines(_ other: TypeRepresenting) -> Bool {
        return name == other.name
            && parameters.count == other.parameters.count
            && !zip(parameters, other.parameters).contains(where: { !$0.refines($1) })
    }
}

public struct TypeParameter {

    public enum Variance {
        case invariant
        case covariant
        case contravariant
    }

    public let variance: Variance
    public let base: TypeRepresenting

    public init(_ variance: Variance, _ base: TypeRepresenting) {
        self.variance = variance
        self.base = base
    }

    public func refines(_ other: TypeParameter) -> Bool {
        assert(variance == other.variance)
        switch variance {
        case .invariant:
            return base.isEqual(to: other.base)
        case .covariant:
            return base.isSubtype(of: other.base)
        case .contravariant:
            return other.base.isSubtype(of: base)
        }
    }

    public func isEqual(to other: TypeParameter) -> Bool {
        return variance == other.variance
            && base.isEqual(to: other.base)
    }
}

public protocol Instance {

    var type: TypeRepresenting { get }
}
