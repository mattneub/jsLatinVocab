import Foundation
@testable import JSLatin
import Testing

struct SwiftSortDescriptorTests {
    @Test("sort descriptor sorts correctly")
    func sortDescriptor() {
        struct Person: Equatable {
            let name: String
            let age: Int
        }
        var persons: [Person] = [Person(name: "Matt", age: 70), Person(name: "Matt", age: 30), Person(name: "Ethan", age: 80)]
        let descriptor1 = SwiftSortDescriptor<Person>.sortFunction { $0.name }
        let descriptor2 = SwiftSortDescriptor<Person>.sortFunction { $0.age }
        persons.sort(by: SwiftSortDescriptor<Person>.combine([descriptor1, descriptor2]))
        #expect(persons == [Person(name: "Ethan", age: 80), Person(name: "Matt", age: 30), Person(name: "Matt", age: 70)])
    }
}
