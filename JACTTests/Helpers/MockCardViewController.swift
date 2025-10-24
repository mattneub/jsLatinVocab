@testable import Jact
import UIKit

final class MockCardViewController: CardViewController {
    var methodsCalled = [String]()
    var hidden: Bool?
    var showing: Bool?

    override func setEnglishHidden(_ hidden: Bool) {
        methodsCalled.append(#function)
        self.hidden = hidden
    }

    override func setExtraShowing(_ showing: Bool) {
        methodsCalled.append(#function)
        self.showing = showing
    }
}
