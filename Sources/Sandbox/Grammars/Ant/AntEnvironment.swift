import Foundation

protocol AntControlling {

    func moveForward()
    func turnLeft()
    func turnRight()

    func foodAhead() -> Bool

    func report()
}

final class AntEnvironment: AntControlling {

    private(set) var field: AntField
    private(set) var antPosition: AntField.Index = (0, 0)
    private(set) var antDirection: AntDirection = .right
    private(set) var antScore = 0
    private(set) var stepCount = 0

    var nextAntPosition: AntField.Index {
        return (
            (field.size.rows + antPosition.row + antDirection.rowIncrement) % field.size.rows,
            (field.size.columns + antPosition.column + antDirection.columnIncrement) % field.size.columns
        )
    }

    init(field: Matrix<AntFieldItem>) {
        self.field = field
        self.field[antPosition] = .ant(antDirection)
    }

    func report() {
        clearScreen()
        print(field)
        Thread.sleep(forTimeInterval: 0.1)
    }

    func moveForward() {
        field[antPosition] = .empty
        antPosition = nextAntPosition
        if case .food = field[antPosition] {
            antScore += 1
        }
        field[antPosition] = .ant(antDirection)
        stepCount += 1
    }

    func turnLeft() {
        antDirection = antDirection.toLeft
        stepCount += 1
    }

    func turnRight() {
        antDirection = antDirection.toRight
        stepCount += 1
    }

    func foodAhead() -> Bool {
        if case .food = field[nextAntPosition] {
            return true
        } else {
            return false
        }
    }
}
