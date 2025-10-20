import UIKit

/// Public face of the root coordinator, so we can mock it.
protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showAllTerms(terms: [Term])
    func showInfo()
    func showLessonList(terms: [Term])
    func dismiss() async
}

/// The root coordinator. This is object that assembles modules and performs transitions between
/// view controllers.
final class RootCoordinator: RootCoordinatorType {
    /// Convenient reference to the root view controller.
    weak var rootViewController: UIViewController?

    /// Place where processors are rooted so that they don't vanish in a puff of smoke.
    var rootProcessor: (any Processor<RootAction, RootState, RootEffect>)?
    var infoProcessor: (any Processor<InfoAction, InfoState, Void>)?
    var lessonListProcessor: (any Processor<LessonListAction, LessonListState, Void>)?
    var allTermsProcessor: (any Processor<AllTermsAction, AllTermsState, Void>)?

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

    func showLessonList(terms: [Term]) {
        let viewController = LessonListViewController()
        let processor = LessonListProcessor()
        self.lessonListProcessor = processor
        processor.coordinator = self
        viewController.processor = processor
        processor.presenter = viewController
        processor.state.terms = terms
        processor.delegate = rootProcessor as? LessonListDelegate
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func showAllTerms(terms: [Term]) {
        let viewController = AllTermsViewController()
        let processor = AllTermsProcessor()
        self.allTermsProcessor = processor
        processor.coordinator = self
        viewController.processor = processor
        processor.presenter = viewController
        processor.state.terms = terms
        processor.delegate = rootProcessor as? AllTermsDelegate
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func dismiss() async {
        await withCheckedContinuation { continuation in
            rootViewController?.dismiss(animated: unlessTesting(true)) {
                continuation.resume(returning: ())
            }
        }
    }
}
