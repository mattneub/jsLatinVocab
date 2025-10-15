import UIKit
@testable import Jact

final class MockPageViewControllerDatasource: PageViewControllerDatasource {
    var thingsReceived = [RootEffect]()

    override func receive(_ effect: RootEffect) async {
        thingsReceived.append(effect)
    }
}
