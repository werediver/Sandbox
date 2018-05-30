struct HashCombiner {

    private(set) var combinedHash: Int = 0

    mutating func combine<T: Hashable>(_ item: T) {
        combine(item.hashValue)
    }

    mutating func combine(_ hash: Int) {
        combinedHash = combinedHash &* 3 &+ hash
    }
}
