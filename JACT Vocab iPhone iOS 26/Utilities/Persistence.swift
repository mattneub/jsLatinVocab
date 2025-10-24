import Foundation

/// Constants used as keys when communicating with user defaults.
struct Defaults {
    static let englishHiddenKey = "englishHidden"
    static let extraShowingKey = "extraShowing"
    static let indexOfCurrentTermKey = "indexOfCurrentTerm"
}

/// Protocol expressing the public face of our Persistence type, so we can mock it for testing.
protocol PersistenceType {
    func setEnglishHidden(_ hidden: Bool)
    func isEnglishHidden() -> Bool
    func setExtraShowing(_ showing: Bool)
    func isExtraShowing() -> Bool
    func setCurrentTermIndex(_ index: Int)
    func currentTermIndex() -> Int?
}

/// Object that communicates with user defaults.
struct Persistence: PersistenceType {
    func setEnglishHidden(_ hidden: Bool) {
        services.userDefaults.set(hidden, forKey: Defaults.englishHiddenKey)
    }

    func isEnglishHidden() -> Bool {
        services.userDefaults.bool(forKey: Defaults.englishHiddenKey)
    }

    func setExtraShowing(_ showing: Bool) {
        services.userDefaults.set(showing, forKey: Defaults.extraShowingKey)
    }

    func isExtraShowing() -> Bool {
        services.userDefaults.bool(forKey: Defaults.extraShowingKey)
    }

    func setCurrentTermIndex(_ index: Int) {
        services.userDefaults.set(index, forKey: Defaults.indexOfCurrentTermKey)
    }

    func currentTermIndex() -> Int? {
        services.userDefaults.object(forKey: Defaults.indexOfCurrentTermKey) as? Int
    }
}
