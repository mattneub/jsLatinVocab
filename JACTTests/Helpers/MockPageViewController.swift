import UIKit

final class MockPageViewController: UIPageViewController {
    var methodsCalled = [String]()
    var viewControllersSet: [UIViewController]?
    var direction: UIPageViewController.NavigationDirection?
    var animated: Bool?

    override func setViewControllers(
        _ viewControllers: [UIViewController]?,
        direction: UIPageViewController.NavigationDirection,
        animated: Bool,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.methodsCalled.append(#function)
        self.viewControllersSet = viewControllers
        self.direction = direction
        self.animated = animated
        super.setViewControllers(
            viewControllers,
            direction: direction,
            animated: false,
            completion: completion
        )
    }
}
