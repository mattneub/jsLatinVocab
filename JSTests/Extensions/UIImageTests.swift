@testable import JSLatin
import Testing
import UIKit
import SnapshotTesting

struct UIImageTests {
    @Test("checkmark image looks correct")
    func checkmark() {
        let result = UIImage.checkmark(ofSize: .init(width: 200, height: 100))
        assertSnapshot(of: result, as: .image(precision: 0.99))
    }
}
