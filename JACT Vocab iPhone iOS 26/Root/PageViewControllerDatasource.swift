import UIKit

/// Class whose instance acts as the page view controller data source and delegate for the page
/// view controller in the root view controller.
class PageViewControllerDatasource<ActionType>: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    /// Reference to the page view controller, so we can talk to it from non-datasource non-delegate
    /// methods.
    weak var pageViewController: UIPageViewController?

    /// Reference to the processor, so we can send actions.
    weak var processor: (any Receiver<ActionType>)? // TODO: might turn out to be unnecessary

    /// Initializer.
    /// - Parameters:
    ///   - pageViewController: Our page view controller.
    ///   - processor: Out processor.
    init(pageViewController: UIPageViewController, processor: (any Receiver<ActionType>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    /// Our data. **This is the source of truth** for the root content.
    var data = [Term]()

    /// Given a term, display that card in the page view controller.
    /// - Parameter term: The term to display.
    func createInitialInterface(term: Term) {
        let card = CardViewController(term: term)
        pageViewController?.setViewControllers([card], direction: .forward, animated: false)
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
        return CardViewController(term: data[index])
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
        return CardViewController(term: data[index])
    }
}
