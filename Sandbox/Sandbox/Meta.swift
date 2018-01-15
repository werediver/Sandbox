public protocol Instance {

    var type: Metatype { get }
}

public protocol Metatype: CustomStringConvertible {

    var name: String { get }
    var parameters: [Variance] { get }

    func isType(of some: Instance) -> Bool
    func isSubtype(of type: Metatype) -> Bool
}

public extension Metatype {

    var description: String {
        return name + (parameters.isEmpty ? "" : "<\(parameters.map(String.init).joined(separator: ", "))>")
    }
}

public func ==(lhs: Metatype, rhs: Metatype) -> Bool {
    return lhs.name == rhs.name
        && zip(lhs.parameters, rhs.parameters).reduce(true, { result, pair in result && pair.0 == pair.1 })
}

public enum Variance {
    case invariant(Metatype)
    case covariant(Metatype)
    case contravariant(Metatype)

    var type: Metatype {
        switch self {
        case let .invariant(type):
            return type
        case let .covariant(type):
            return type
        case let .contravariant(type):
            return type
        }
    }

    func isCompatible(with other: Variance) -> Bool {
        switch (self, other) {
        case let (.invariant(a), .invariant(b)):
            return a == b
        case let (.covariant(a), .covariant(b)):
            return a.isSubtype(of: b)
        case let (.contravariant(a), .contravariant(b)):
            return b.isSubtype(of: a)
        case (.invariant, _), (.covariant, _), (.contravariant, _):
            return false
        }
    }
}

extension Variance: Equatable {

    public static func ==(lhs: Variance, rhs: Variance) -> Bool {
        switch (lhs, rhs) {
        case (.invariant, .invariant), (.covariant, .covariant), (.contravariant, .contravariant):
            return lhs.type == rhs.type
        case (.invariant, _), (.covariant, _), (.contravariant, _):
            return false
        }
    }
}

extension Variance: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .invariant(type):
            return "invariant(\(type))"
        case let .covariant(type):
            return "covariant(\(type))"
        case let .contravariant(type):
            return "contravariant(\(type))"
        }
    }
}
