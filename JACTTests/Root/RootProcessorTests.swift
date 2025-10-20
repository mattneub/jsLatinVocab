@testable import Jact
import Testing
import Foundation

struct RootProcessorTests {
    let subject = RootProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<RootEffect, RootState>()
    let bundle = MockBundle()
    let persistence = MockPersistence()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        services.bundle = bundle
        services.persistence = persistence
    }

    @Test("initialInterface: fetches string file from bundle, creates and sorts Terms, sets state, presents, navigates")
    func initialInterface() async {
        let path = Bundle(for: MockBundle.self).path(forResource: "dataUnsorted", ofType: "txt") // see Fixtures
        bundle.pathToReturn = path
        persistence.hiddenToReturn = true
        await subject.receive(.initialInterface)
        let terms = subject.state.terms
        // terms are in order by lessonSection
        #expect(terms.map { $0.lessonSection } == ["01a", "01b", "03b", "03b", "03b"])
        // where two terms have same lessonSection, they are in beta order
        #expect(terms[2].beta < terms[3].beta)
        // but if they have same beta too, they are in original order
        #expect(terms[3].beta == terms[4].beta)
        #expect(terms[3].indexOrig < terms[4].indexOrig)
        // `index` has been renumbered in current order
        #expect(terms.map { $0.index } == [0, 1, 2, 3, 4])
        // and it has been presented
        #expect(presenter.statesPresented.last == subject.state)
        // and we pass persistence english hidden to presenter
        #expect(persistence.methodsCalled == ["isEnglishHidden()"])
        #expect(presenter.thingsReceived.first == .englishHidden(true))
        // and we navigate
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, style: .noAnimation))
    }

    @Test("showInfo: calls coordinator showInfo")
    func showInfo() async {
        await subject.receive(.showInfo)
        #expect(coordinator.methodsCalled == ["showInfo()"])
    }

    @Test("showLessonList: calls coordinator showLessonList with terms")
    func showLessonList() async {
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
        await subject.receive(.showLessonList)
        #expect(coordinator.methodsCalled == ["showLessonList(terms:)"])
        #expect(coordinator.terms == [term1, term2])
    }

    @Test("tappedLabel: correctly sends navigate to correct index")
    func tappedLabel() async {
        let path = Bundle(for: MockBundle.self).path(forResource: "dataSorted", ofType: "txt")! // see Fixtures
        var terms = try! String(contentsOfFile: path, encoding: .utf8)
            .components(separatedBy: "\n")
            .filter { $0.count > 5 }
            .map { Term(tabbedString: $0, index: 0)}
        for index in terms.indices {
            var term = terms[index]
            term.index = index
            terms[index] = term
        }
        subject.state.terms = terms
        await subject.receive(.tappedLabel(.lesson, currentTerm: 0))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 2, style: .forward))
        await subject.receive(.tappedLabel(.lesson, currentTerm: 2))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, style: .forward))
        await subject.receive(.tappedLabel(.section, currentTerm: 0))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 1, style: .forward))
        await subject.receive(.tappedLabel(.section, currentTerm: 1))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 2, style: .forward))
        await subject.receive(.tappedLabel(.section, currentTerm: 2))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, style: .forward))
    }

    @Test("toggleEnglish: toggle english hidden in persistence, passes new value to presenter")
    func toggleEnglish() async {
        persistence.hiddenToReturn = false
        await subject.receive(.toggleEnglish)
        #expect(persistence.methodsCalled == ["isEnglishHidden()", "setEnglishHidden(_:)"])
        #expect(persistence.hidden == true)
        #expect(presenter.thingsReceived.last == .englishHidden(true))
        persistence.hiddenToReturn = true
        persistence.methodsCalled = []
        await subject.receive(.toggleEnglish)
        #expect(persistence.methodsCalled == ["isEnglishHidden()", "setEnglishHidden(_:)"])
        #expect(persistence.hidden == false)
        #expect(presenter.thingsReceived.last == .englishHidden(false))
    }

    @Test("navigateTo: sends presenter navigateTo")
    func navigateToIndex() async {
        await subject.navigateTo(index: 4)
        #expect(presenter.thingsReceived.last == .navigateTo(index: 4, style: .appropriate))
    }

    @Test("termChosen: sends navigateTo for the corresponding term's index")
    func termChosen() async {
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
        await subject.termChosen(indexOrig: 2)
        #expect(presenter.thingsReceived == [.navigateTo(index: 1, style: .appropriate)])
    }
}

