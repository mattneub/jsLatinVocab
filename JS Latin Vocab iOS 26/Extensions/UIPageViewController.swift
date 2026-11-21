import UIKit

extension UIPageViewController {
    /// Async version of `setViewControllers`.
    ///
    /// For the trick of boxing the continuation into an Optional and then
    /// resuming and consuming it in a single move, see
    /// https://forums.swift.org/t/cant-convert-from-checkedcontinuation-to-continuation/90899/2
    func setViewControllers(
        _ viewControllers: [UIViewController]?,
        direction: UIPageViewController.NavigationDirection,
        animated: Bool
    ) async {
        await withContinuation(of: Void.self) { continuation in
            var continuation = Optional(continuation)
            setViewControllers(
                viewControllers,
                direction: direction,
                animated: animated,
                completion: { _ in
                    continuation.take()?.resume()
                }
            )
        }
    }
}
