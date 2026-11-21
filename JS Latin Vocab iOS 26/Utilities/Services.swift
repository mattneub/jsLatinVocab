import UIKit

/// Class whose single instance provides access to externalities.
final class Services {
    var bundle: any BundleType = #bundle
    var persistence: any PersistenceType = Persistence()
    var sceneSizeRestrictor: any SceneSizeRestrictorType = SceneSizeRestrictor()
    var userDefaults: any UserDefaultsType = UserDefaults.standard
}
