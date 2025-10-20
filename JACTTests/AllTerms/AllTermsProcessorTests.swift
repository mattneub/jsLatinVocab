@testable import Jact
import Testing
import Foundation

struct AllTermsProcessorTests {
    let subject = AllTermsProcessor()
    let presenter = MockReceiverPresenter<Void, AllTermsState>()
    let coordinator = MockRootCoordinator()
    let delegate = MockAllTermsDelegate()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        subject.delegate = delegate
    }

    @Test("cancel: calls coordinator dismiss")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("initialInterface: presents the current state")
    func initialInterface() async {
        subject.state.terms = [Term(tabbedString: "a\tb\tc\td\te", index: 1)]
        await subject.receive(.initialInterface)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("termChosen: call coordinator dismiss, calls delegate termChosen")
    func termChosen() async {
        await subject.receive(.termChosen(666))
        #expect(coordinator.methodsCalled == ["dismiss()"])
        #expect(delegate.methodsCalled == ["termChosen(indexOrig:)"])
        #expect(delegate.indexOrig == 666)
    }
}

final class MockAllTermsDelegate: AllTermsDelegate {
    var methodsCalled = [String]()
    var indexOrig: Int?

    func termChosen(indexOrig: Int) async {
        methodsCalled.append(#function)
        self.indexOrig = indexOrig
    }
}
