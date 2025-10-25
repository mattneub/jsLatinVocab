/// Swift sort descriptor lifted and neatened slightly
/// from http://chris.eidhof.nl/post/sort-descriptors-in-swift/
///
/// This has the advantage that we don't have to use NSSortDescriptor and we don't have to
/// grapple with Swift SortComparator and key paths with are not sendable.
struct SwiftSortDescriptor<Value> {
    typealias SortFunction = (Value, Value) -> Bool

    static func sortFunction<Key>(
        _ propertyGetter: @escaping (Value) -> Key,
        _ sortFunction: @escaping (Key, Key) -> Bool
    ) -> SortFunction {
        return { sortFunction(propertyGetter($0), propertyGetter($1)) }
    }

    static func sortFunction<Key>(
        _ propertyGetter: @escaping (Value) -> Key
    ) -> SortFunction where Key: Comparable {
        return { propertyGetter($0) < propertyGetter($1) }
    }

    /// This is the Really Important Part: it lets us build a "complex" sort descriptor
    /// that orders by successive values (i.e. if two values are equal, we use the next value),
    /// similar to the way an NSSortDescriptor works.
    static func combine(_ sortFunctions: [SortFunction]) -> SortFunction {
        return { lhs, rhs in
            for isOrdered in sortFunctions {
                if isOrdered(lhs, rhs) { return true }
                if isOrdered(rhs, lhs) { return false }
            }
            return false
        }
    }
}
