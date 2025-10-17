import UIKit
@testable import Jact
import Testing
import WaitWhile

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
        #expect(window.backgroundColor == .systemBackground)
    }

    @Test("showInfo: configures info module, presents navigation controller")
    func showInfo() async throws {
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        subject.showInfo()
        let processor = try #require(subject.infoProcessor as? InfoProcessor)
        let infoController = try #require(processor.presenter as? InfoViewController)
        #expect(processor.coordinator === subject)
        #expect(infoController.processor === processor)
        await #while(viewController.presentedViewController == nil)
        let navigationController = try #require(viewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === infoController)
        #expect(navigationController.modalPresentationStyle == .fullScreen)
        #expect(navigationController.modalTransitionStyle == .flipHorizontal)
    }

    @Test("dismiss: dismisses from root view controller")
    func dismiss() async throws {
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let viewController2 = UIViewController()
        viewController.present(viewController2, animated: false)
        await #while(viewController.presentedViewController == nil)
        #expect(viewController.presentedViewController === viewController2)
        subject.dismiss()
        await #while(viewController.presentedViewController != nil)
        #expect(viewController.presentedViewController == nil)
    }
}
