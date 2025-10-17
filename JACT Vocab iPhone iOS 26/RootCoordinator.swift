import UIKit

/// Public face of the root coordinator, so we can mock it.
protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showInfo()
    func dismiss()
}

/// The root coordinator. This is object that assembles modules and performs transitions between
/// view controllers.
final class RootCoordinator: RootCoordinatorType {
    /// Convenient reference to the root view controller.
    weak var rootViewController: UIViewController?

    /// Place where processors are rooted so that they don't vanish in a puff of smoke.
    var rootProcessor: (any Processor<RootAction, RootState, RootEffect>)?
    var infoProcessor: (any Processor<InfoAction, InfoState, Void>)?

    func createInterface(window: UIWindow) {
        let rootViewController = RootViewController()
        self.rootViewController = rootViewController
        let processor = RootProcessor()
        self.rootProcessor = processor
        processor.presenter = rootViewController
        rootViewController.processor = processor
        processor.coordinator = self
        window.rootViewController = rootViewController
        window.backgroundColor = .systemBackground
    }

    func showInfo() {
        let infoController = InfoViewController()
        let processor = InfoProcessor()
        self.infoProcessor = processor
        processor.coordinator = self
        infoController.processor = processor
        processor.presenter = infoController
        let navigationController = UINavigationController(rootViewController: infoController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .flipHorizontal
        rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func dismiss() {
        rootViewController?.dismiss(animated: unlessTesting(true))
    }
}
