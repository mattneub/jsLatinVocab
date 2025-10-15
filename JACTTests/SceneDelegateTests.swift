import Testing
@testable import Jact
import UIKit
import WaitWhile

struct SceneDelegateTests {
    @Test("bootstrap behaves correctly")
    func bootstrap() throws {
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.coordinator = mockRootCoordinator
        subject.bootstrap(scene: scene)
        #expect(mockRootCoordinator.methodsCalled == ["createInterface(window:)"])
        #expect(mockRootCoordinator.window === subject.window)
    }
}
