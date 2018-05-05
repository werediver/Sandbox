import Foundation

struct AntFieldLoader {

    public enum Failure: Error {

        case cannotOpenFileForReading
        case invalidEncoding
    }

    static func load(from path: String) throws -> Matrix<AntFieldItem> {

        guard let file = FileHandle(forReadingAtPath: path)
        else { throw Failure.cannotOpenFileForReading }

        let data = file.readDataToEndOfFile()

        guard let text = String(data: data, encoding: .utf8)
        else { throw Failure.invalidEncoding }

        var matrix = Matrix<AntFieldItem>(repeating: .empty, size: (32, 32))

        var lineIndex = 0
        var column = 0

        text.enumerateLines { line, _ in
            if lineIndex > 0 {
                line.dropFirst(1).forEach { character in
                    if isFood(character) {
                        let row = lineIndex - 1
                        matrix[row, column] = .food
                        column += 1
                    } else if isEmpty(character) {
                        column += 1
                    }
                }
            }
            lineIndex += 1
            column = 0
        }

        return matrix
    }

    private static func isFood(_ character: Character) -> Bool {
        return character == "X"
    }

    private static func isEmpty(_ character: Character) -> Bool {
        return character == "."
    }
}
