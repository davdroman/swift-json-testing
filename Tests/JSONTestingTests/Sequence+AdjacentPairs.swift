import Foundation

struct PairSequence<S: Sequence>: IteratorProtocol, Sequence {
    var iterator: S.Iterator
    var last: S.Element?

    init(sequence: S) {
        iterator = sequence.makeIterator()
        last = iterator.next()
    }

    mutating func next() -> (S.Element, S.Element)? {
        guard let a = last, let b = iterator.next() else { return nil }
        last = b
        return (a, b)
    }
}

extension Sequence {
    func adjacentPairs() -> PairSequence<Self> {
        return PairSequence(sequence: self)
    }
}
