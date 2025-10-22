@testable import Jact
import Testing
import UIKit
import WaitWhile

struct LessonListDrillViewControllerTests {
    let subject = LessonListDrillViewController()
    let processor = MockReceiver<LessonListDrillAction>()
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
        let clearButton = try #require(subject.navigationItem.leftBarButtonItems?[1])
        #expect(clearButton.target === subject)
        #expect(clearButton.action == #selector(subject.clear))
        let drillButton = try #require(subject.navigationItem.rightBarButtonItem)
        #expect(drillButton.target === subject)
        #expect(drillButton.action == #selector(subject.drill))
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
        let state = LessonListDrillState(terms: terms)
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.state == state)
    }

    @Test("receive: passes effect to the datasource")
    func receive() async {
        await subject.receive(.clear)
        #expect(datasource.thingsReceived == [.clear])
    }

    @Test("cancel: sends cancel")
    func cancel() async {
        subject.cancel()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .cancel)
    }

    @Test("clear: sends clear")
    func clear() async {
        subject.clear()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .clear)
    }

    @Test("drill: sends drill to datasource")
    func drill() async {
        subject.drill()
        await #while(datasource.thingsReceived.isEmpty)
        #expect(datasource.thingsReceived.first == .drill)
    }

    @Test("navigation controller supported orientations is all three")
    func supported() {
        let result = subject.navigationControllerSupportedInterfaceOrientations(UINavigationController())
        #expect(result == [.landscape])
    }
}

private final class MockDatasource: NSObject, @MainActor LessonListDrillDatasourceType {
    typealias State = LessonListDrillState
    typealias Received = LessonListDrillEffect

    var methodsCalled = [String]()
    var thingsReceived = [LessonListDrillEffect]()
    var state: LessonListDrillState?

    func present(_ state: LessonListDrillState) async {
        methodsCalled.append(#function)
        self.state = state
    }

    func receive(_ effect: LessonListDrillEffect) async {
        thingsReceived.append(effect)
    }
}
