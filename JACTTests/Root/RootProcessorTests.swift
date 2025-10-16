@testable import Jact
import Testing
import Foundation

struct RootProcessorTests {
    let subject = RootProcessor()
    let presenter = MockReceiverPresenter<RootEffect, RootState>()
    let bundle = MockBundle()
    let persistence = MockPersistence()

    init() {
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
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, animated: false))
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
        #expect(presenter.thingsReceived.last == .navigateTo(index: 2, animated: true))
        await subject.receive(.tappedLabel(.lesson, currentTerm: 2))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, animated: true))
        await subject.receive(.tappedLabel(.section, currentTerm: 0))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 1, animated: true))
        await subject.receive(.tappedLabel(.section, currentTerm: 1))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 2, animated: true))
        await subject.receive(.tappedLabel(.section, currentTerm: 2))
        #expect(presenter.thingsReceived.last == .navigateTo(index: 0, animated: true))
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
}

