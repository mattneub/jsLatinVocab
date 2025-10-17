@testable import Jact
import Testing
import Foundation

struct InfoProcessorTests {
    let subject = InfoProcessor()
    let presenter = MockReceiverPresenter<Void, InfoState>()
    let bundle = MockBundle()
    let coordinator = MockRootCoordinator()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.bundle = bundle
    }

    @Test("receive done: calls coordinator dismiss")
    func done() async {
        await subject.receive(.done)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("receive initialInterface: fetches resource from bundle, configures state, presents")
    func initialInterface() async {
        let path = Bundle(for: MockBundle.self).path(forResource: "content", ofType: "html")! // see Fixtures
        bundle.pathToReturn = path
        await subject.receive(.initialInterface)
        #expect(bundle.methodsCalled == ["path(forResource:ofType:)"])
        #expect(bundle.resource == "jactVocabHelp")
        #expect(bundle.type == "html")
        #expect(subject.state.content == "howdy\n")
        #expect(subject.state.url == URL(fileURLWithPath: path))
        #expect(presenter.statesPresented.first == subject.state)
    }
}


