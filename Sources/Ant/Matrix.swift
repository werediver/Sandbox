public struct Matrix<Item> {

    public typealias Size = (rows: Int, columns: Int)
    public typealias Index = (row: Int, column: Int)

    public let size: Size

    public private(set) var items: [Item]

    public init(repeating item: Item, size: Size) {
        self.size = size
        self.items = [Item](repeating: item, count: size.rows * size.columns)
    }

    public subscript(index: Index) -> Item {
        get { return self[index.row, index.column] }
        set { self[index.row, index.column] = newValue }
    }

    public subscript(row: Int, column: Int) -> Item {
        get { return items[offset(row: row, column: column)] }
        set { items[offset(row: row, column: column)] = newValue }
    }

    public subscript(row: Int) -> Array<Item>.SubSequence {
        return items[offset(row: row, column: 0) ... offset(row: row, column: size.columns - 1)]
    }

    private func offset(row: Int, column: Int) -> Int {
        assert(row < size.rows)
        assert(column < size.columns)
        return row * size.columns + column
    }
}

extension Matrix: CustomStringConvertible {

    public var description: String { return description(size: size) }

    public func description(size: Size) -> String {
        var text = ""
        for row in 0 ..< size.rows {
            for column in 0 ..< size.columns {
                text += "\(self[row, column]) "
            }
            text += "\n"
        }
        return text
    }
}
