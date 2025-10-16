@testable import Jact
import Testing
import Foundation

struct PersistenceTests {
    let subject = Persistence()
    let defaults = MockUserDefaults()

    init() {
        services.userDefaults = defaults
    }

    @Test("setEnglishHidden sets bool for given key")
    func setEnglishHidden() throws {
        subject.setEnglishHidden(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let value = try #require(defaults.thingsSet["englishHidden"] as? Bool)
        #expect(value == true)
    }

    @Test("isEnglishHidden fetches bool for given key")
    func isEnglishHidden() throws {
        defaults.thingsToReturn["englishHidden"] = false
        let value = subject.isEnglishHidden()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(value == false)
        defaults.methodsCalled = []
        defaults.thingsToReturn["englishHidden"] = true
        let value2 = subject.isEnglishHidden()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(value2 == true)
    }
}
