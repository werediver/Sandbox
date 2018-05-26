import class Foundation.DispatchQueue
import class Foundation.DispatchGroup
import struct Foundation.CharacterSet

public extension Population {

    func evaluateAllConcurrently() {
        var evaluatedItems = [Item]()
        evaluatedItems.reserveCapacity(preferredCount + 1)

        let qLabel = #function.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        let q = DispatchQueue(label: qLabel, attributes: .concurrent)
        let group = DispatchGroup()

        items.forEach { item in
            group.enter()
            if item.score != nil {
                q.async(flags: .barrier) {
                    evaluatedItems.append(item)
                    group.leave()
                }
            } else {
                q.async {
                    let evaluatedItem = item.scored(self.evaluate(item.genotype))
                    q.async(flags: .barrier) {
                        evaluatedItems.append(evaluatedItem)
                        group.leave()
                    }
                }
            }
        }

        group.wait()

        items = evaluatedItems
    }
}
