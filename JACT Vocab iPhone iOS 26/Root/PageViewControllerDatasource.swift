import UIKit

/// Class whose instance acts as the page view controller data source and delegate for the page
/// view controller in the root view controller.
class PageViewControllerDatasource: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    /// Reference to the page view controller, so we can talk to it from non-datasource non-delegate
    /// methods.
    weak var pageViewController: UIPageViewController?

    /// Reference to the processor, so we can send actions and/or configure card controllers to send actions.
    weak var processor: (any Receiver<RootAction>)?

    /// Initializer.
    /// - Parameters:
    ///   - pageViewController: Our page view controller.
    ///   - processor: Out processor.
    init(pageViewController: UIPageViewController, processor: (any Receiver<RootAction>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    /// Our data.
    var data = [Term]()

    func receive(_ effect: RootEffect) async {
        switch effect {
        case .navigateTo(index: let index, animated: let animated):
            navigateTo(index: index, animated: animated)
        }
    }

    /// Navigate to the given Terms index, animated or not.
    func navigateTo(index: Int, animated: Bool) {
        guard data.indices.contains(index) else {
            return
        }
        let term = data[index]
        let card = CardViewController(term: term)
        card.processor = processor
        pageViewController?.setViewControllers([card], direction: .forward, animated: animated)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let indexOrig = (viewController as? CardViewController)?.term.indexOrig else {
            return nil
        }
        guard var index = data.firstIndex(where: { $0.indexOrig == indexOrig }) else {
            return nil
        }
        index -= 1
        if index < 0 {
            return nil
        }
        let card = CardViewController(term: data[index])
        card.processor = processor
        return card
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let indexOrig = (viewController as? CardViewController)?.term.indexOrig else {
            return nil
        }
        guard var index = data.firstIndex(where: { $0.indexOrig == indexOrig }) else {
            return nil
        }
        index += 1
        if index >= data.count {
            return nil
        }
        let card = CardViewController(term: data[index])
        card.processor = processor
        return card
    }
}
