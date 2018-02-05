public struct Nothing: ValueType {

    public init() {}

    public struct Value: AnyValue {

        public var type: AnyType { return Nothing() }

        public init() {}
    }
}

public struct Function: ValueType {

    public var name: String { return "\(Function.self)<\(input.name)), \(output.name)>" }

    public let input: AnyType
    public let output: AnyType

    public init(input: AnyType, output: AnyType) {
        self.input = input
        self.output = output
    }

    public func equals(to other: AnyType) -> Bool {
        return (other as? Function).map { other in
                return input.equals(to: other.input)
                    && output.equals(to: other.output)
            }
            ?? false
    }

    public struct Value: AnyValue {

        public typealias Body = (AnyValue) -> AnyValue

        public let body: Body

        public let type: AnyType

        public init(type: Function, body: @escaping Body) {
            self.type = type
            self.body = { input in
                assert(type.input.isType(of: input), "Function input type mismatch")
                let output = body(input)
                assert(type.output.isType(of: output), "Function output type mismatch")
                return output
            }
        }

        public init<T: ValueType, U: ValueType>(input: T, output: U, body: @escaping (T.Value) -> U.Value) {
            self.init(
                type: .init(input: input, output: output),
                body: { input in body(input as! T.Value) }
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
