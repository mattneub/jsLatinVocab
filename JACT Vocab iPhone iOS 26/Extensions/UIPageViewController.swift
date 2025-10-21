import UIKit

extension UIPageViewController {
    /// Async version of `setViewControllers`.
    func setViewControllers(
        _ viewControllers: [UIViewController]?,
        direction: UIPageViewController.NavigationDirection,
        animated: Bool
    ) async {
        await withCheckedContinuation { continuation in
            setViewControllers(
                viewControllers,
                direction: direction,
                animated: animated,
                completion: { _ in continuation.resume(returning: ()) }
            )
        }
    }
}
