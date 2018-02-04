protocol AnyValue {

    var type: AnyType { get }
}

protocol AnyType {

    var name: String { get }

    func equals(to other: AnyType) -> Bool
    func isType(of value: AnyValue) -> Bool
}

protocol ValueType: AnyType {

    associatedtype Value: AnyValue
}

extension ValueType {

    func isType(of value: AnyValue) -> Bool {
        return value is Value && equals(to: value.type)
    }
}

struct Nothing: ValueType {

    var name: String { return "\(Nothing.self)" }

    init() {}

    func equals(to other: AnyType) -> Bool {
        return other is Nothing
    }

    struct Value: AnyValue {

        let type: AnyType = Nothing()

        init() {}
    }
}

struct Function: ValueType {

    var name: String { return "(\(input.name)) -> \(output.name)" }

    let input: AnyType
    let output: AnyType

    init(input: AnyType, output: AnyType) {
        self.input = input
        self.output = output
    }

    func equals(to other: AnyType) -> Bool {
        return (other as? Function).map { other in
                return other.input.equals(to: input)
                    && other.output.equals(to: output)
            }
            ?? false
    }

    struct Value: AnyValue {

        typealias Body = (AnyValue) -> AnyValue

        let body: Body

        let type: AnyType

        init(type: Function, body: @escaping Body) {
            self.type = type
            // TODO: Add dynamic type-checking
            self.body = body
        }
    }
}

struct Credit: ValueType {

    var name: String { return "\(Credit.self)" }

    init() {}

    func equals(to other: AnyType) -> Bool {
        return other is Credit
    }

    struct Value: AnyValue {

        let amount: Int

        let type: AnyType = Credit()

        init(amount: Int) {
            self.amount = amount
        }
    }
}

let c = Credit.Value(amount: 10)
let f = Function.Value(
    type: .init(input: Credit(), output: Nothing()),
    body: { value in dump(value); return Nothing.Value() }
)
f.body(c)
