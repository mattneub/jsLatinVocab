@testable import Jact
import Testing
import Foundation

struct RootProcessorTests {
    let subject = RootProcessor()
    let presenter = MockReceiverPresenter<Void, RootState>()
    let bundle = MockBundle()

    init() {
        subject.presenter = presenter
        services.bundle = bundle
    }

    @Test("initialInterface: fetches string file from bundle, creates and sorts Terms, sets state, presents")
    func initialInterface() async {
        let path = Bundle(for: MockBundle.self).path(forResource: "testing", ofType: "txt")
        bundle.pathToReturn = path
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
        // initial term is first term as sorted
        #expect(subject.state.initialTerm == terms[0])
        // and it has been presented
        #expect(presenter.statesPresented.last == subject.state)
    }
}

