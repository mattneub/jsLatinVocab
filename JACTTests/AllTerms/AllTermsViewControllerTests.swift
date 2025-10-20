@testable import Jact
import Testing
import UIKit
import WaitWhile

struct AllTermsViewControllerTests {
    let subject = AllTermsViewController()
    let processor = MockReceiver<AllTermsAction>()
    fileprivate let datasource = MockDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("initialize: sets tableview style, background color")
    func initialize() {
        #expect(subject.tableView.style == .plain)
        #expect(subject.tableView.backgroundColor == .myGolden.withAlphaComponent(1))
    }

    @Test("viewDidLoad: configures left bar button item, sends initialInterface")
    func viewDidLoad() async throws {
        subject.loadViewIfNeeded()
        let button = try #require(subject.navigationItem.leftBarButtonItem)
        #expect(button.target === subject)
        #expect(button.action == #selector(subject.cancel))
        await #while (processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialInterface])
    }

    @Test("present: presents to the datasource")
    func present() async {
        let state = AllTermsState(terms: [Term(tabbedString: "a\tb\tc\td\te", index: 1)])
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.state == state)
    }

    @Test("cancel: sends .cancel")
    func cancel() async {
        subject.cancel()
        await #while (processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .cancel)
    }
}

private final class MockDatasource: NSObject, @MainActor AllTermsDatasourceType {
    typealias State = AllTermsState

    var methodsCalled = [String]()
    var state: AllTermsState?

    func present(_ state: AllTermsState) async {
        methodsCalled.append(#function)
        self.state = state
    }
}

