@testable import Jact
import Testing
import UIKit
import SnapshotTesting

struct DoneViewControllerTests {
    let subject = DoneViewController()

    @Test("image view looks correct")
    func imageView() {
        makeWindow(viewController: subject)
        subject.view.layoutIfNeeded()
        subject.checkImage.backgroundColor = .black
        assertSnapshot(of: subject.checkImage, as: .image)
    }

    @Test("image view is correctly configured")
    func imageViewConfigured() {
        let subject = subject.checkImage
        #expect(subject.contentMode == .center)
        #expect(subject.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("viewDidLoad: positions image view, sets background color")
    func viewDidLoad() {
        makeWindow(viewController: subject)
        subject.view.layoutIfNeeded()
        #expect(subject.view.backgroundColor == .black)
        #expect(subject.checkImage.superview == subject.view)
        let bounds = subject.view.bounds
        #expect(subject.checkImage.center == CGPoint(x: bounds.midX, y: bounds.midY))
    }
}
