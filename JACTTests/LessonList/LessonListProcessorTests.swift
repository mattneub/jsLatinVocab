@testable import Jact
import Testing
import Foundation

struct LessonListProcessorTests {
    let subject = LessonListProcessor()
    let presenter = MockReceiverPresenter<Void, LessonListState>()
    let coordinator = MockRootCoordinator()
    let delegate = MockLessonListDelegate()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        subject.delegate = delegate
    }

    @Test("cancel: tells the coordinator to dismiss")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("initialData: presents the current state")
    func initialData() async {
        let string1 = "latin\tenglish\t2\ta\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tb another word\tpart"
        let string4 = "latin\tenglish\t1\tc\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        subject.state = .init(terms: terms)
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("selectedLessonSection: finds index of first matching term, tells delegate to navigate")
    func selectedLessonSection() async {
        let string1 = "latin\tenglish\t1\tb another word\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tc\tpart"
        let string4 = "latin\tenglish\t2\ta\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        subject.state = .init(terms: terms)
        await subject.receive(.selectedLessonSection("1b"))
        #expect(delegate.methodsCalled == ["navigateTo(index:)"])
        #expect(delegate.index == 0)
    }
}

final class MockLessonListDelegate: LessonListDelegate {
    var methodsCalled = [String]()
    var index = -1

    func navigateTo(index: Int) async {
        methodsCalled.append(#function)
        self.index = index
    }
}
