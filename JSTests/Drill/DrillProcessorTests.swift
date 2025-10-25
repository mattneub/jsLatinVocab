@testable import JSLatin
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

    @Test("cancel: calls coordinator dismiss")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("initialInterface: presents existing state, navigates to first one, configures state")
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
        let term = subject.state.terms[0]
        #expect(presenter.thingsReceived == [.navigateTo(indexOrig: term.indexOrig, style: .noAnimation)])
        #expect(subject.state.currentTermIndexOrig == term.indexOrig)
        #expect(subject.state.originalCount == 2)
    }

    @Test("right: removes term with indexOrig matching currentTermIndexOrig")
    func rightRemove() async {
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
        subject.state.currentTermIndexOrig = 2
        subject.state.originalCount = 2
        await subject.receive(.right)
        #expect(subject.state.terms == [term1])
    }

    @Test("right: if terms now empty, sends progress 0, sends done, calls coordinator dismiss")
    func rightEmpty() async{
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 3
        )
        subject.state.terms = [term2]
        subject.state.currentTermIndexOrig = 2
        subject.state.originalCount = 1
        await subject.receive(.right)
        #expect(presenter.thingsReceived == [.progress(0), .done])
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("right: removes current term, navigates to term now at that index, sends progress")
    func rightKeepsIndex() async {
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
        let term3 = Term(
            latin: "latin3", latinFirstWord: "", beta: "", english: "english3", lesson: "lesson2",
            section: "section3", sectionFirstWord: "", lessonSection: "", part: "part3",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 3, index: 4
        )
        subject.state.terms = [term1, term2, term3]
        subject.state.currentTermIndexOrig = 2
        subject.state.originalCount = 4
        await subject.receive(.right)
        #expect(subject.state.terms == [term1, term3])
        #expect(subject.state.currentTermIndexOrig == 3)
        #expect(presenter.thingsReceived.count == 2)
        #expect(presenter.thingsReceived[0] == .navigateTo(indexOrig: 3, style: .forward))
        #expect(presenter.thingsReceived[1] == .progress(0.5))
    }

    @Test("right: removes current term, if no term at that index now, resets index to 0 and shuffles")
    func rightResetsIndex() async {
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
        let term3 = Term(
            latin: "latin3", latinFirstWord: "", beta: "", english: "english3", lesson: "lesson2",
            section: "section3", sectionFirstWord: "", lessonSection: "", part: "part3",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 3, index: 4
        )
        subject.state.terms = [term1, term2, term3]
        subject.state.currentTermIndexOrig = 3
        subject.state.originalCount = 4
        await subject.receive(.right)
        #expect(subject.state.terms.count == 2)
        #expect(subject.state.terms.contains(term1))
        #expect(subject.state.terms.contains(term2))
        let indexOrig = subject.state.terms[0].indexOrig
        #expect(subject.state.currentTermIndexOrig == indexOrig)
        #expect(presenter.thingsReceived.count == 2)
        #expect(presenter.thingsReceived[0] == .navigateTo(indexOrig: indexOrig, style: .forward))
        #expect(presenter.thingsReceived[1] == .progress(0.5))
    }

    @Test("showEnglish: sends showEnglish")
    func showEnglish() async {
        await subject.receive(.showEnglish)
        #expect(presenter.thingsReceived == [.showEnglish])
    }

    @Test("wrong: advances index if possible, leaving terms unchanged")
    func wrong() async {
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
        let term3 = Term(
            latin: "latin3", latinFirstWord: "", beta: "", english: "english3", lesson: "lesson2",
            section: "section3", sectionFirstWord: "", lessonSection: "", part: "part3",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 3, index: 4
        )
        subject.state.terms = [term1, term2, term3]
        subject.state.currentTermIndexOrig = 1
        await subject.receive(.wrong)
        #expect(subject.state.terms == [term1, term2, term3])
        #expect(subject.state.currentTermIndexOrig == 2)
        #expect(presenter.thingsReceived == [.navigateTo(indexOrig: 2, style: .forward)])
    }

    @Test("wrong: if cannot advance index, resets to 0, shuffles")
    func wrongReset() async {
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
        let term3 = Term(
            latin: "latin3", latinFirstWord: "", beta: "", english: "english3", lesson: "lesson2",
            section: "section3", sectionFirstWord: "", lessonSection: "", part: "part3",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 3, index: 4
        )
        subject.state.terms = [term1, term2, term3]
        subject.state.currentTermIndexOrig = 3
        await subject.receive(.wrong)
        #expect(subject.state.terms.count == 3)
        #expect(subject.state.terms.contains(term1))
        #expect(subject.state.terms.contains(term2))
        #expect(subject.state.terms.contains(term3))
        let indexOrig = subject.state.terms[0].indexOrig
        #expect(subject.state.currentTermIndexOrig == indexOrig)
        #expect(presenter.thingsReceived == [.navigateTo(indexOrig: indexOrig, style: .forward)])
    }
}


