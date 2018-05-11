import struct Foundation.CharacterSet

extension String {

    func indented(_ prefix: String = "    ") -> String {
        return components(separatedBy: .newlines)
            .map { line in line.isEmpty ? line : prefix + line }
            .joined(separator: "\n")
    }
}
