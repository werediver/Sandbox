// Would be good to constraint `NativeType` to be a subtype of `Instance`, but it makes impossible to
// define `Anything` (with `NativeType` set to `Instance`), because
// "Using 'Instance' as a concrete type conforming to protocol 'Instance' is not supported"
public final class Type<T>: TypeRepresenting {

    public let name: String
    public let parameters: [TypeParameter]
    let supertypes: [TypeRepresenting]

    public init(name: String = "\(T.self)", supertypes: [TypeRepresenting] = [Anything.type], parameters: [TypeParameter] = []) {
        self.name = name
        self.supertypes = supertypes
        self.parameters = parameters
    }

    public func isType(of some: Instance) -> Bool {
        return some is T
            && some.type.isSubtype(of: self)
            && !supertypes.contains(where: { !$0.isType(of: some) })
    }

    public func isSubtype(of other: TypeRepresenting) -> Bool {
        return refines(other)
            || supertypes.contains(where: { $0.isSubtype(of: other) })
    }
}

//extension Type: CustomStringConvertible {
//
//    var description: String {
//        return name + parameters.map
//    }
//}

public enum Failure: Error {
    case typeMismatch(actual: TypeRepresenting, expected: TypeRepresenting)
}

public struct Anything: Instance {

    public static let type = Type<Instance>(name: "\(Anything.self)", supertypes: [])

    public var type: TypeRepresenting { return Anything.type }
}

public struct Nothing: Instance {

    public static let instance = Nothing()

    public static let type = Type<Nothing>()

    public var type: TypeRepresenting { return Anything.type }
}

public struct Function: Instance {

    public typealias Body = (Instance) -> Instance

    public static func type(input: TypeRepresenting, output: TypeRepresenting) -> TypeRepresenting {
        return Type<Function>(parameters: [TypeParameter(.contravariant, input), TypeParameter(.covariant, output)])
    }

    public let type: TypeRepresenting
    public let body: Body

    public init(input: TypeRepresenting, output: TypeRepresenting, body: @escaping Body) {
        self.type = Function.type(input: input, output: output)
        self.body = body
    }
}

public struct Credit: Instance {

    public static let type = Type<Credit>()

    public var type: TypeRepresenting { return Credit.type }
    public let amount: Int

    public init(amount: Int) {
        self.amount = amount
    }
}

public struct Maybe: Instance {

    public static func type(_ valueType: TypeRepresenting) -> TypeRepresenting {
        return Type<Maybe>(parameters: [TypeParameter(.covariant, valueType)])
    }

    public let type: TypeRepresenting
    public let value: Instance?

    init(value: Instance) throws { try self.init(value.type, value: value) }

    init(_ valueType: TypeRepresenting, value: Instance?) throws {
        if let value = value {
            guard valueType.isType(of: value)
            else { throw Failure.typeMismatch(actual: value.type, expected: valueType) }
        }

        self.type = Maybe.type(valueType)
        self.value = value
    }
}

public struct List: Instance {

    public static func type(of itemType: TypeRepresenting) -> TypeRepresenting {
        return Type<List>(parameters: [TypeParameter(.covariant, itemType)])
    }

    public let type: TypeRepresenting
    public let itemType: TypeRepresenting
    public let items: [Instance]

    init(of itemType: TypeRepresenting, items: [Instance]) throws {
        for item in items {
            guard itemType.isType(of: item)
            else { throw Failure.typeMismatch(actual: item.type, expected: itemType) }
        }

        self.type = List.type(of: itemType)
        self.itemType = itemType
        self.items = items
    }
}
