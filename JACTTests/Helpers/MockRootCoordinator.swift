@testable import Jact
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: UIWindow?
    var terms = [Term]()

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showInfo() {
        methodsCalled.append(#function)
    }

    func dismiss() {
        methodsCalled.append(#function)
    }

    func showLessonList(terms: [Jact.Term]) {
        methodsCalled.append(#function)
        self.terms = terms
    }

    func showLessonListDrill(terms: [Jact.Term]) {
        methodsCalled.append(#function)
        self.terms = terms
    }

    func showAllTerms(terms: [Jact.Term]) {
        methodsCalled.append(#function)
        self.terms = terms
    }

}
