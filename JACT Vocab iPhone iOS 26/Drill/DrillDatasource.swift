import UIKit

/// Class whose instance acts as the page view controller data source and delegate for the page
/// view controller in the drill view controller.
final class DrillDatasource: NSObject, PageViewControllerDatasourceType {
    /// Reference to the page view controller, so we can talk to it from non-datasource non-delegate
    /// methods.
    weak var pageViewController: UIPageViewController?

    /// Reference to the processor, so we can send actions.
    weak var processor: (any Receiver<DrillAction>)? // TODO: Might not need this

    /// Type of the card view controller that we will use as the child of the page view controller.
    /// This is so that a test can inject a mock version.
    var cardClass: CardViewController.Type = DrillCardViewController.self

    /// Initializer.
    /// - Parameters:
    ///   - pageViewController: Our page view controller.
    ///   - processor: Our processor.
    init(pageViewController: UIPageViewController, processor: (any Receiver<DrillAction>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    /// Our data.
    var data = [Term]()

    /// The processor communicates with us by sending us an Effect.
    func receive(_ effect: DrillEffect) async {
        switch effect {
        case .navigateTo(index: let index, style: let style):
            await navigateTo(index: index, style: style)
        }
    }

    /// Navigate to the given Terms index, animated or not.
    func navigateTo(index: Int, style: NavigationStyle) async {
        guard data.indices.contains(index) else {
            return
        }
        let term = data[index]
        let card = cardClass.init(term: term)
        card.loadViewIfNeeded()
        card.setEnglishHidden(true)
        let (animate, direction): (Bool, UIPageViewController.NavigationDirection) = {
            switch style {
            case .noAnimation: return (false, .forward)
            case .forward: return (true, .forward)
            case .appropriate:
                if let currentCard = pageViewController?.viewControllers?.first as? CardViewController {
                    if index < currentCard.term.index {
                        return (true, .reverse)
                    }
                }
                return (true, .forward)
            }
        }()
        await pageViewController?.setViewControllers([card], direction: direction, animated: animate)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
}
