import UIKit

/// Where the services are rooted.
let services = Services()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    /// Allow rotation to portrait (for all terms view controller), only _after_ launch.
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        [.landscape, .portrait] // allow app to rotate to portrait, but only _after_ launch has finished
    }
}

