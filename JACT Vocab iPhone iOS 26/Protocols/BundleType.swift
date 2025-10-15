import Foundation

protocol BundleType {
    func path(forResource: String?, ofType: String?) -> String?
}

extension Bundle: BundleType {}
