import UIKit
@testable import Jact

final class MockPageViewControllerDatasource: PageViewControllerDatasource<RootAction> {
    var methodsCalled = [String]()
    var term: Term?

    override func createInitialInterface(term: Term) {
        methodsCalled.append(#function)
        self.term = term
    }
}
