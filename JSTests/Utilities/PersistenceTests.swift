@testable import JSLatin
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

    @Test("setCurrentTermIndex sets int for given key")
    func setCurrentTermIndex() throws {
        subject.setCurrentTermIndex(999)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let value = try #require(defaults.thingsSet["indexOfCurrentTerm"] as? Int)
        #expect(value == 999)
    }

    @Test("currentTermIndex returns optional int")
    func currentTermIndex() throws {
        defaults.thingsToReturn = [:]
        let value = subject.currentTermIndex()
        #expect(defaults.methodsCalled == ["object(forKey:)"])
        #expect(value == nil)
        defaults.methodsCalled = []
        defaults.thingsToReturn = ["indexOfCurrentTerm": "bad value"]
        let value2 = subject.currentTermIndex()
        #expect(defaults.methodsCalled == ["object(forKey:)"])
        #expect(value2 == nil)
        defaults.methodsCalled = []
        defaults.thingsToReturn = ["indexOfCurrentTerm": 999]
        let value3 = subject.currentTermIndex()
        #expect(defaults.methodsCalled == ["object(forKey:)"])
        #expect(value3 == 999)
    }
}
