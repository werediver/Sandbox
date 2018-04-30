public typealias AntField = Matrix<AntFieldItem>

public enum AntFieldItem: CustomStringConvertible {

    case empty
    case food
    case ant(AntDirection)

    public var description: String {
        switch self {
        case .empty:
            return "·"
        case .food:
            return "◼"
        case let .ant(direction):
            switch direction {
            case .right:
                return "▶"
            case .up:
                return "▲"
            case .left:
                return "◀"
            case .down:
                return "▼"
            }
        }
    }
}

public enum AntDirection {

    case right
    case up
    case left
    case down

    var rowIncrement: Int {
        switch self {
        case .right:
            return 0
        case .up:
            return -1
        case .left:
            return 0
        case .down:
            return 1
        }
    }

    var columnIncrement: Int {
        switch self {
        case .right:
            return 1
        case .up:
            return 0
        case .left:
            return -1
        case .down:
            return 0
        }
    }

    var toRight: AntDirection {
        switch self {
        case .right:
            return .down
        case .up:
            return .right
        case .left:
            return .up
        case .down:
            return .left
        }
    }

    var toLeft: AntDirection {
        switch self {
        case .right:
            return .up
        case .up:
            return .left
        case .left:
            return .down
        case .down:
            return .right
        }
    }
}
