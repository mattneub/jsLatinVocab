@testable import Jact
import UIKit

final class MockCardViewController: CardViewController {
    var methodsCalled = [String]()
    var hidden: Bool?

    override func setEnglishHidden(_ hidden: Bool) {
        methodsCalled.append(#function)
        self.hidden = hidden
    }
}
