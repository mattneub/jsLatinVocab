import Foundation
@testable import JSLatin

final class MockBundle: BundleType {
    var methodsCalled = [String]()
    var pathToReturn: String?
    var resource: String?
    var type: String?

    func path(forResource: String?, ofType: String?) -> String? {
        methodsCalled.append(#function)
        self.resource = forResource
        self.type = ofType
        return pathToReturn
    }
}
