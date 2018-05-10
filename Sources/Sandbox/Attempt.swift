typealias AttemptRetry = () throws -> Never

func attempt<T>(limit: Int, file: String = #file, line: Int = #line, _ body: (AttemptRetry) throws -> T) throws -> T {

    let retry: AttemptRetry = { throw AttemptFailure.retry }

    for _ in 0 ..< limit {
        do {
            return try body(retry)
        } catch AttemptFailure.retry {
            continue
        }
    }

    throw AttemptFailure.limitExceeded(file: file, line: line)
}

func attempt<T>(limit: Int, file: String = #file, line: Int = #line, _ body: () throws -> T) throws -> T {

    for _ in 0 ..< limit {
        do {
            return try body()
        } catch {
            continue
        }
    }

    throw AttemptFailure.limitExceeded(file: file, line: line)
}

enum AttemptFailure: Error {

    case retry
    case limitExceeded(file: String, line: Int)
}

extension AttemptFailure: CustomStringConvertible {

    var description: String {
        switch self {
        case .retry:
            return "retry"
        case let .limitExceeded(file, line):
            return "attempt limit exceeded for operation started from \(file):\(line)"
        }
    }
}
