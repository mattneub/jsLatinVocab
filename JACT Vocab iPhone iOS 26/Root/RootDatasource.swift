import UIKit

/// Class whose instance acts as the page view controller data source and delegate for the page
/// view controller in the root view controller.
final class RootDatasource: NSObject, PageViewControllerDatasourceType {
    /// Reference to the page view controller, so we can talk to it from non-datasource non-delegate
    /// methods.
    weak var pageViewController: UIPageViewController?

    /// Reference to the processor, so we can send actions and/or configure card controllers to send actions.
    weak var processor: (any Receiver<RootAction>)?

    /// Type of the card view controller that we will use as the child of the page view controller.
    /// This is so that a test can inject a mock version.
    var cardClass: CardViewController.Type = CardViewController.self

    /// Initializer.
    /// - Parameters:
    ///   - pageViewController: Our page view controller.
    ///   - processor: Our processor.
    init(pageViewController: UIPageViewController, processor: (any Receiver<RootAction>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    /// Our data.
    var data = [Term]()

    /// Current state of whether the English label is hidden or not. This too is part of our
    /// data, because we need to know it in order to navigate to a new card when the user taps
    /// (i.e. as part of our role as data source).
    var englishHidden = false

    /// The processor communicates with us by sending us an Effect.
    func receive(_ effect: RootEffect) async {
        switch effect {
        case .englishHidden(let hidden):
            self.englishHidden = hidden
            (pageViewController?.viewControllers?.first as? CardViewController)?.setEnglishHidden(hidden)
        case .navigateTo(index: let index, style: let animated):
            navigateTo(index: index, style: animated)
        }
    }

    /// Navigate to the given Terms index, animated or not.
    func navigateTo(index: Int, style: NavigationStyle) {
        guard data.indices.contains(index) else {
            return
        }
        let term = data[index]
        let card = cardClass.init(term: term)
        card.loadViewIfNeeded()
        card.processor = processor
        card.setEnglishHidden(englishHidden)
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
        pageViewController?.setViewControllers([card], direction: direction, animated: animate)
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
        let card = cardClass.init(term: data[index])
        card.loadViewIfNeeded()
        card.processor = processor
        card.setEnglishHidden(englishHidden)
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
        let card = cardClass.init(term: data[index])
        card.loadViewIfNeeded()
        card.processor = processor
        card.setEnglishHidden(englishHidden)
        return card
    }
}
