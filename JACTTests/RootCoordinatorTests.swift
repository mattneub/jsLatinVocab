import UIKit
@testable import Jact
import Testing

struct RootCoordinatorTests {
    @Test("createInterface: configures initial module correctly")
    func createInterface() throws {
        let subject = RootCoordinator()
        let window = UIWindow()
        subject.createInterface(window: window)
        let viewController = try #require(subject.rootViewController as? RootViewController)
        let processor = try #require(viewController.processor as? RootProcessor)
        #expect(subject.rootProcessor === processor)
        #expect(processor.presenter === viewController)
        #expect(processor.coordinator === subject)
        #expect(window.rootViewController === viewController)
        #expect(window.backgroundColor == .white)
    }
}
