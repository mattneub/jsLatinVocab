@testable import JSLatin
import UIKit
import Testing

struct AppDelegateTests {
    @Test("supported orientations is right")
    func supported() {
        let subject = AppDelegate()
        let result = subject.application(UIApplication.shared, supportedInterfaceOrientationsFor: UIWindow())
        #expect(result == [.portrait, .landscape])
    }
}
