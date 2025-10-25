@testable import JSLatin
import Testing
import UIKit

struct LessonListDrillCellTests {
    @Test("cell adds background image when selected, removes when deselected")
    func cellImage() async throws {
        let subject = LessonListDrillCell(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        subject.backgroundConfiguration = UIBackgroundConfiguration.listCell()
        subject.backgroundConfiguration?.backgroundColor = .myPaler
        #expect(subject.backgroundConfiguration?.image == nil)
        var state = subject.configurationState
        state.isSelected = true
        subject.updateConfiguration(using: state)
        #expect(subject.backgroundConfiguration?.image != nil)
        state.isSelected = false
        subject.updateConfiguration(using: state)
        #expect(subject.backgroundConfiguration?.image == nil)
    }
}
