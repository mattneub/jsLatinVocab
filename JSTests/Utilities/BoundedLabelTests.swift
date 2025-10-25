@testable import JSLatin
import Testing
import UIKit
import SnapshotTesting

struct BoundedLabelTests {
    @Test("bounded label looks correct")
    func boundedLabelAppearance() {
        let subject = BoundedLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        subject.awakeFromNib()
        subject.text = "This is a test!"
        assertSnapshot(of: subject, as: .image)
    }
}
