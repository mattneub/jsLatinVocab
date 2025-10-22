@testable import Jact
import Testing
import Foundation

struct DrillProcessorTests {
    let subject = DrillProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<DrillEffect, DrillState>()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
    }

    @Test("initialInterface: presents existing state, navigates to first one")
    func initialInterface() async {
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 3
        )
        subject.state.terms = [term1, term2]
        await subject.receive(.initialInterface)
        #expect(presenter.statesPresented == [.init(terms: [term1, term2])])
        #expect(presenter.thingsReceived == [.navigateTo(index: 0, style: .noAnimation)])
    }
}

