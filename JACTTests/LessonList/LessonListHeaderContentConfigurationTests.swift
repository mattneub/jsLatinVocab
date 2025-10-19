@testable import Jact
import Testing
import UIKit

struct LessonListHeaderContentConfigurationTests {
    @Test("configuration correctly constructs its view")
    func configuration() throws {
        let configuration = LessonListHeaderContentConfiguration(text: "Testing")
        let cell = UICollectionViewCell()
        cell.contentConfiguration = configuration
        let contentView = try #require(cell.contentView as? LessonListHeaderContentView)
        let label = try #require(contentView.subviews.first as? UILabel)
        #expect(label.text == "Testing")
        #expect(label.frame == CGRect(x: 10, y: 0, width: 100, height: 40))
        #expect(label.font == UIFont(name:"GillSans-Bold", size:20))
        #expect(label.backgroundColor == .clear)
        #expect(label.textColor == .myPaler)
    }
}
