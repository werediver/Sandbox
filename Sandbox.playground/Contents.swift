import Sandbox

func inspect<T>(_ body: () throws -> T) -> T! {
    do {
        let result = try body()
        print("✔ \(result)")
        return result
    } catch {
        print("✘ \(error)")
        return nil
    }
}

let f = Function.Value(
    input: Credit(),
    output: Nothing(),
    body: { value in dump(value); return Nothing.Value() }
)

f.body(Credit.Value(amount: 10))
