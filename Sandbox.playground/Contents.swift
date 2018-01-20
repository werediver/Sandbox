import Sandbox

final class DummyContext: Context {

    func execute(_ executable: Executable) {}
}

func examine<T>(_ body: () throws -> T) -> T? {
    do {
        let result = try body()
        print("✔ \(result)")
        return result
    } catch {
        print("✘ \(error)")
        return nil
    }
}

let findCredit = GenericExecutable(name: "FindCredit", types: (Nothing.type, Credit.type)) { _, _ in Credit(amount: 1) }
let consumeCredit = GenericExecutable(name: "ConsumeCredit", types: (Credit.type, Nothing.type)) { _, food in
    print("Consumed: \(food)")
    return Nothing.instance
}

let program = examine { try findCredit.composed(with: [consumeCredit]) }!

examine { try program.execute(in: DummyContext(), with: Nothing.instance) }
