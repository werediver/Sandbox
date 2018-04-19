public struct Nothing: ValueType {

    public init() {}

    public struct Value: AnyValue {

        public var type: AnyType { return Nothing() }

        public init() {}
    }
}

public struct Function: ValueType {

    public var name: String {
        return "\(Function.self)<\(input.map { $0.name } .joined(separator: ", "))), \(output.name)>"
    }

    public let input: [AnyType]
    public let output: AnyType

    public init(input: [AnyType], output: AnyType) {
        self.input = input
        self.output = output
    }

    public func equals(to other: AnyType) -> Bool {
        return (other as? Function).map { other in
                return input.count == other.input.count
                    && zip(input, other.input).reduce(true) { result, pair in result && pair.0.equals(to: pair.1) }
                    && output.equals(to: other.output)
            }
            ?? false
    }

    public struct Value: AnyValue {

        public typealias Body = ([AnyValue]) -> AnyValue

        public let body: Body

        public let type: AnyType

        public init(type: Function, body: @escaping Body) {
            self.type = type
            self.body = { input in
                assert(input.count == type.input.count, "Function arguments count mismatch")
                assert(zip(input, type.input).reduce(true) { result, pair in result && pair.1.isType(of: pair.0) }, "Function argument type mismatch")
                let output = body(input)
                assert(type.output.isType(of: output), "Function output type mismatch")
                return output
            }
        }

        public init<T1: ValueType, U: ValueType>(input parameter1: T1, output: U, body: @escaping (T1.Value) -> U.Value) {
            self.init(
                type: .init(input: [parameter1], output: output),
                body: { input in body(input[0] as! T1.Value) }
            )
        }

        public init<T1: ValueType, T2: ValueType, U: ValueType>(input parameter1: T1, _ parameter2: T2, output: U, body: @escaping (T1.Value, T2.Value) -> U.Value) {
            self.init(
                type: .init(input: [parameter1, parameter2], output: output),
                body: { input in body(input[0] as! T1.Value, input[1] as! T2.Value) }
            )
        }
    }
}

public struct List: ValueType {

    public var name: String { return "\(List.self)<\(item.name)>" }

    public let item: AnyType

    public init(of item: AnyType) {
        self.item = item
    }

    public func equals(to other: AnyType) -> Bool {
        return (other as? List).map { other in
                item.equals(to: other.item)
            }
            ?? false
    }

    public struct Value: AnyValue {

        public let items: [AnyValue]

        public let type: AnyType

        public init(type: List, items: [AnyValue]) {
            assert(items.reduce(true, { result, item in result && type.item.isType(of: item) }), "List item type mismatch")

            self.type = type
            self.items = items
        }
    }
}

public struct Maybe: ValueType {

    public var name: String { return "\(Maybe.self)<\(value.name)>" }

    public let value: AnyType

    public init(_ value: AnyType) {
        self.value = value
    }

    public func equals(to other: AnyType) -> Bool {
        return (other as? Maybe).map { other in
                value.equals(to: other.value)
            }
            ?? false
    }

    public struct Value: AnyValue {

        public let value: AnyValue?

        public let type: AnyType

        public init(type: Maybe, value: AnyValue?) {
            self.type = type
            self.value = value
        }

    }
}

public struct Credit: ValueType {

    public init() {}

    public struct Value: AnyValue {

        public let amount: Int

        public var type: AnyType { return Credit() }

        public init(amount: Int) {
            self.amount = amount
        }
    }
}
