struct Matrix<Item> {

    typealias Size = (rows: Int, columns: Int)
    typealias Index = (row: Int, column: Int)

    let size: Size
    var items: [Item]

    init(repeating item: Item, size: Size) {
        self.size = size
        self.items = [Item](repeating: item, count: size.rows * size.columns)
    }

    subscript(index: Index) -> Item {
        get { return self[index.row, index.column] }
        set { self[index.row, index.column] = newValue }
    }

    subscript(row: Int, column: Int) -> Item {
        get { return items[offset(row: row, column: column)] }
        set { items[offset(row: row, column: column)] = newValue }
    }

    subscript(row: Int) -> Array<Item>.SubSequence {
        return items[offset(row: row, column: 0) ... offset(row: row, column: size.columns - 1)]
    }

    private func offset(row: Int, column: Int) -> Int {
        assert(row < size.rows)
        assert(column < size.columns)
        return row * size.columns + column
    }
}

extension Matrix: CustomStringConvertible {

    var description: String {
        var text = ""
        for row in 0 ..< size.rows {
            for item in self[row] {
                text += "\(item) "
            }
            text += "\n"
        }
        return text
    }
}
