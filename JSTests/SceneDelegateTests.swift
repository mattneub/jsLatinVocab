import Testing
@testable import JSLatin
import UIKit
import WaitWhile

struct SceneDelegateTests {
    @Test("bootstrap behaves correctly")
    func bootstrap() throws {
        let restrictor = MockSceneSizeRestrictor()
        services.sceneSizeRestrictor = restrictor
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.coordinator = mockRootCoordinator
        subject.bootstrap(scene: scene)
        #expect(mockRootCoordinator.methodsCalled == ["createInterface(window:)"])
        #expect(mockRootCoordinator.window === subject.window)
        #expect(restrictor.scene === scene)
        #expect(restrictor.minimumSize == .init(width: 844, height: 390))
        #expect(restrictor.maximumSize == .init(width: 1000, height: 450))
    }
}
