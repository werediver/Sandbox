public struct AntEnvironmentFactory {

    private let field: AntField

    public init(field: AntField) {
        self.field = field
    }

    public func make(onChange: AntEnvironment.OnChange? = nil) -> AntEnvironment {
        return AntEnvironment(field: field, onChange: onChange)
    }
}
