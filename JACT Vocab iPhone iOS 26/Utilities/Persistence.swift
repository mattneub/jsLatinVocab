import Foundation

/// Constants used as keys when communicating with user defaults.
struct Defaults {
    static let englishHiddenKey = "englishHidden"
    static let indexOfCurrentTermKey = "indexOfCurrentTerm"
}

/// Protocol expressing the public face of our Persistence type, so we can mock it for testing.
protocol PersistenceType {
    func setEnglishHidden(_ hidden: Bool)
    func isEnglishHidden() -> Bool
}

/// Object that communicates with user defaults.
struct Persistence: PersistenceType {
    func setEnglishHidden(_ hidden: Bool) {
        services.userDefaults.set(hidden, forKey: Defaults.englishHiddenKey)
    }

    func isEnglishHidden() -> Bool {
        services.userDefaults.bool(forKey: Defaults.englishHiddenKey)
    }
}
