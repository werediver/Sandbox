public extension List {

    var takeFirst: Function.Value {
        return Function.Value(
            input: self,
            output: Maybe(item),
            body: { [item] input in
                Maybe.Value(type: .init(item), value: input.items.first)
            }
        )
    }
}
