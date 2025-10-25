@testable import JSLatin
import Testing
import Foundation

struct LessonListDrillProcessorTests {
    let subject = LessonListDrillProcessor()
    let presenter = MockReceiverPresenter<LessonListDrillEffect, LessonListDrillState>()
    let coordinator = MockRootCoordinator()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
    }

    @Test("cancel: tells the coordinator to dismiss")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("clear: sends clear")
    func clear() async {
        await subject.receive(.clear)
        #expect(presenter.thingsReceived == [.clear])
    }

    @Test("drill: sends drill")
    func drill() async {
        await subject.receive(.drill)
        #expect(presenter.thingsReceived == [.drill])
    }

    @Test("drillUsing: extracts terms with given lesson/section(s), calls coordinator showDrill")
    func drillUsing() async {
        let string1 = "latin1\tenglish\t2\ta\tpart"
        let string2 = "latin2\tenglish\t1\tb\tpart"
        let string3 = "latin3\tenglish\t1\tb another word\tpart"
        let string4 = "latin4\tenglish\t1\tc\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        subject.state = .init(terms: terms)
        await subject.receive(.drillUsing([
            .init(lesson: "2", section: "a"),
            .init(lesson: "1", section: "c"),
        ]))
        #expect(coordinator.methodsCalled == ["showDrill(terms:)"])
        #expect(coordinator.terms.map { $0.latin } == ["latin1", "latin4"])
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

}
