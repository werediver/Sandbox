public protocol AnyValue {

    var type: AnyType { get }
}

public protocol AnyType {

    var name: String { get }

    func equals(to other: AnyType) -> Bool
    func isType(of value: AnyValue) -> Bool
}

public extension AnyType {

    var name: String { return "\(Self.self)" }

    func equals(to other: AnyType) -> Bool {
        return other is Self
    }
}

public protocol ValueType: AnyType {

    associatedtype Value: AnyValue
}

public extension ValueType {

    func isType(of value: AnyValue) -> Bool {
        return value is Value && equals(to: value.type)
    }
}
