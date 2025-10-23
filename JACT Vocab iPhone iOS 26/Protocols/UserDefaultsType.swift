import Foundation

/// Protocol describing our interactions with user defaults, so we can mock it for testing.
protocol UserDefaultsType {
    func set(_: Bool, forKey: String)
    func set(_: Int, forKey: String)
    func bool(forKey: String) -> Bool
    func object(forKey: String) -> Any?
}

extension UserDefaults: UserDefaultsType {}
