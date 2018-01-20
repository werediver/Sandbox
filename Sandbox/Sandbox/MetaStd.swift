// Would be good to constraint `NativeType` to be a subtype of `Instance`, but it makes impossible to
// define `Anything` (with `NativeType` set to `Instance`), because
// "Using 'Instance' as a concrete type conforming to protocol 'Instance' is not supported"
public struct Type<T>: Metatype {

    public let name: String
    public let parameters: [Variance]
    let supertypes: [Metatype]

    public init(name: String = "\(T.self)", supertypes: [Metatype] = [Anything.type], parameters: [Variance] = []) {
        self.name = name
        self.supertypes = supertypes
        self.parameters = parameters
    }

    public func isType(of some: Instance) -> Bool {
        // TBD: Should `isSubtype(of:)` be checked here as well?
        return supertypes.reduce(some is T, { result, supertype in result && supertype.isType(of: some) })
    }

    public func isSubtype(of type: Metatype) -> Bool {
        let result = name == type.name
            && parameters.count == type.parameters.count
            && zip(parameters, type.parameters).reduce(true) { result, pair in
                result && pair.0.isCompatible(with: pair.1)
            }
        return supertypes.reduce(result, { result, supertype in result || supertype.isSubtype(of: type) })
    }
}

public enum Failure: Error {
    case typeMismatch(actual: Metatype, expected: Metatype)
}

public struct Anything: Instance {

    public static let type = Type<Instance>(name: "Anything", supertypes: [])

    public var type: Metatype { return Anything.type }
}

public struct Nothing: Instance {

    public static let instance = Nothing()

    public static let type = Type<Nothing>()

    public var type: Metatype { return Anything.type }
}

public struct Credit: Instance {

    public static let type = Type<Credit>()

    public var type: Metatype { return Credit.type }
    public let amount: Int

    public init(amount: Int) {
        self.amount = amount
    }
}

public struct Maybe: Instance {

    public static func type(_ valueType: Metatype) -> Metatype {
        return Type<Maybe>(parameters: [.covariant(valueType)])
    }

    public let type: Metatype
    public let value: Instance?

    init(value: Instance) throws { try self.init(value.type, value: value) }

    init(_ valueType: Metatype, value: Instance?) throws {
        if let value = value {
            guard valueType.isType(of: value)
            else { throw Failure.typeMismatch(actual: value.type, expected: valueType) }
        }

        self.type = Maybe.type(valueType)
        self.value = value
    }
}

public struct List: Instance {

    public static func type(of itemType: Metatype) -> Metatype {
        return Type<List>(parameters: [.covariant(itemType)])
    }

    public let type: Metatype
    public let itemType: Metatype
    public let items: [Instance]

    init(of itemType: Metatype, items: [Instance]) throws {
        for item in items {
            guard itemType.isType(of: item)
            else { throw Failure.typeMismatch(actual: item.type, expected: itemType) }
        }

        self.type = List.type(of: itemType)
        self.itemType = itemType
        self.items = items
    }
}
