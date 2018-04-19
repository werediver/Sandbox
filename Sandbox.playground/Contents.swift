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
    input: Credit(), Credit(),
    output: Nothing(),
    body: { c1, c2 in dump(c1); dump(c2); return Nothing.Value() }
)

f.body([Credit.Value(amount: 10), Credit.Value(amount: 20)])
