import Foundation

public func rand(below upperBound: Int = Int(Int32.max)) -> Int {
    return Int(arc4random_uniform(UInt32(upperBound)))
}
