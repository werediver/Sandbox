public protocol SomeGrammar {

    associatedtype Result

    static func generate(_ rule: GenotypeIterating) throws -> Result
}
