import UIKit

/// Class whose single instance provides access to externalities.
final class Services {
    var bundle: BundleType = Bundle.main
    var persistence: PersistenceType = Persistence()
    var userDefaults: UserDefaultsType = UserDefaults.standard
}
