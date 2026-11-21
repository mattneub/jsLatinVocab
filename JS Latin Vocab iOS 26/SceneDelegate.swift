import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var coordinator: (any RootCoordinatorType) = RootCoordinator()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else {
            return
        }
        unlessTesting {
            bootstrap(scene: scene)
        }
    }

    func bootstrap(scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        self.window = window
        coordinator.createInterface(window: window)
        window.makeKeyAndVisible()
        services.sceneSizeRestrictor.restrict(
            scene: scene,
            minimumSize: .init(width: 844, height: 390),
            maximumSize: .init(width: 1000, height: 450)
        )
    }

    /// duplicates what the app delegate does; I expect eventually the app delegate
    /// method will be deprecated in favor of this one
    func supportedInterfaceOrientations(
        for scene: UIWindowScene
    ) -> UIInterfaceOrientationMask {
        [.landscape, .portrait] // allow app to rotate to portrait, but only _after_ launch has finished
    }
}

