import UIKit

/// Public face of the root coordinator, so we can mock it.
protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
}

/// The root coordinator. This is object that assembles modules and performs transitions between
/// view controllers.
final class RootCoordinator: RootCoordinatorType {
    /// Convenient reference to the root view controller.
    weak var rootViewController: UIViewController?

    /// Place where processors are rooted so that they don't vanish in a puff of smoke.
    var rootProcessor: (any Processor<RootAction, RootState, RootEffect>)?

    func createInterface(window: UIWindow) {
        let rootViewController = RootViewController()
        self.rootViewController = rootViewController
        let processor = RootProcessor()
        self.rootProcessor = processor
        processor.presenter = rootViewController
        rootViewController.processor = processor
        processor.coordinator = self
        window.rootViewController = rootViewController
        window.backgroundColor = .white
    }
}
