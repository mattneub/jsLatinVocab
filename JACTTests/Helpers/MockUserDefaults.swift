import Foundation
@testable import Jact

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var thingsSet = [String: Any?]()
    var thingsToReturn = [String: Any?]()

    func set(_ value: Bool, forKey key: String) {
        methodsCalled.append(#function)
        thingsSet[key] = value
    }
    
    func bool(forKey key: String) -> Bool {
        methodsCalled.append(#function)
        if let value = thingsToReturn[key] as? Bool {
            return value
        }
        fatalError("thingsToReturn not prepared with Bool for key \(key)")
    }
    

}
