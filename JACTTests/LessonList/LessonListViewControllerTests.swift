@testable import Jact
import Testing
import UIKit
import WaitWhile

struct LessonListViewControllerTests {
    let subject = LessonListViewController()
    let processor = MockReceiver<LessonListAction>()
    fileprivate let datasource = MockDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("initialize: configures layout as flow layout")
    func initialize() {
        #expect(subject.collectionView.collectionViewLayout is UICollectionViewFlowLayout)
    }

    @Test("viewDidLoad: sets up cancel button, collection view, interface style, sends initialData")
    func viewDidLoad() async throws {
        subject.loadViewIfNeeded()
        let cancelButton = try #require(subject.navigationItem.leftBarButtonItem)
        #expect(cancelButton.target === subject)
        #expect(cancelButton.action == #selector(subject.cancel))
        #expect(subject.collectionView.backgroundColor == .myGolden.withAlphaComponent(1))
        #expect(subject.collectionView.contentInsetAdjustmentBehavior == .always)
        #expect(subject.collectionView.topEdgeEffect.isHidden == true)
        #expect(subject.overrideUserInterfaceStyle == .light)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .initialData)
    }

    @Test("present: presents to the datasource")
    func present() async {
        let string1 = "latin\tenglish\t1\tb another word\tpart"
        let string2 = "latin\tenglish\t1\tb\tpart"
        let string3 = "latin\tenglish\t1\tc\tpart"
        let string4 = "latin\tenglish\t2\ta\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        let state = LessonListState(terms: terms)
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.state == state)
    }

    @Test("cancel: sends cancel")
    func cancel() async {
        subject.cancel(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .cancel)
    }
}

private final class MockDatasource: NSObject, @MainActor LessonListDatasourceType {
    typealias State = LessonListState

    var methodsCalled = [String]()
    var state: LessonListState?

    func present(_ state: LessonListState) async {
        methodsCalled.append(#function)
        self.state = state
    }
}
