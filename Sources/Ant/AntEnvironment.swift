public final class AntEnvironment: AntControllable {

    public typealias OnChange = (AntEnvironment) -> Void

    public private(set) var field: AntField
    private let initialFoodCount: Int
    private(set) var antPosition: AntField.Index = (0, 0)
    private(set) var antDirection: AntDirection = .right
    public var foodLeft: Int { return initialFoodCount - antScore }
    public private(set) var antScore = 0
    public private(set) var stepCount = 0
    private let onChange: OnChange?

    var nextAntPosition: AntField.Index {
        return (
            (field.size.rows + antPosition.row + antDirection.rowIncrement) % field.size.rows,
            (field.size.columns + antPosition.column + antDirection.columnIncrement) % field.size.columns
        )
    }

    public init(field: AntField, onChange: OnChange? = nil) {
        self.field = field
        self.field[antPosition] = .ant(antDirection)
        self.onChange = onChange

        var foodCount = 0
        for item in field.items {
            if case .food = item {
                foodCount += 1
            }
        }
        self.initialFoodCount = foodCount
    }

    public func moveForward() {
        field[antPosition] = .empty
        antPosition = nextAntPosition
        if case .food = field[antPosition] {
            antScore += 1
        }
        field[antPosition] = .ant(antDirection)
        stepCount += 1
        onChange?(self)
    }

    public func turnLeft() {
        antDirection = antDirection.toLeft
        field[antPosition] = .ant(antDirection)
        stepCount += 1
        onChange?(self)
    }

    public func turnRight() {
        antDirection = antDirection.toRight
        field[antPosition] = .ant(antDirection)
        stepCount += 1
        onChange?(self)
    }

    public func foodAhead() -> Bool {
        if case .food = field[nextAntPosition] {
            return true
        } else {
            return false
        }
    }
}
