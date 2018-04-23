import Foundation

func rand(below: Int = Int(Int32.max)) -> Int {
    return Int(arc4random_uniform(UInt32(below)))
}
