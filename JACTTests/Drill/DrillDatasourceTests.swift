@testable import Jact
import Testing
import UIKit

struct DrillDatasourceTests {
    var subject: DrillDatasource!
    let pageViewController = MockPageViewController()
    let processor = MockReceiver<DrillAction>()

    init() {
        subject = DrillDatasource(pageViewController: pageViewController, processor: processor)
        subject.cardClass = MockCardViewController.self
    }

    @Test("done: creates done view controller, navigates to it")
    func done() async throws {
        await subject.receive(.done)
        #expect(pageViewController.viewControllers?.first is DoneViewController)
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == true)
    }

    @Test("receive navigateTo: creates card of the correct class")
    func navigateToClass() async throws {
        let subject = DrillDatasource(pageViewController: pageViewController, processor: processor)
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        await subject.receive(.navigateTo(indexOrig: 1, style: .noAnimation))
        let card = try #require(pageViewController.viewControllers?.first as? DrillCardViewController)
        #expect(type(of: card) == DrillCardViewController.self)
        #expect(card.term == term)
    }

    @Test("receive navigateTo: given term indexOrig, creates card view controller and puts it in page view controller")
    func navigateTo() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        await subject.receive(.navigateTo(indexOrig: 1, style: .noAnimation))
        let card = try #require(pageViewController.viewControllers?.first as? MockCardViewController)
        #expect(card.term == term)
        #expect(card.processor == nil)
        #expect(card.methodsCalled == ["setEnglishHidden(_:)"])
        #expect(card.hidden == true)
    }

    @Test("receive navigateTo: style correctly determines setViewControllers parameters")
    func navigateToStyle() async throws {
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 0
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        subject.data = [term1, term2]
        await subject.receive(.navigateTo(indexOrig: 1, style: .noAnimation))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == false)
        pageViewController.methodsCalled = []
        await subject.receive(.navigateTo(indexOrig: 1, style: .forward))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == true)
        pageViewController.methodsCalled = []
        // we don't expect to get `.appropriate`, but if we did we would go forward without animation
        await subject.receive(.navigateTo(indexOrig: 2, style: .appropriate))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == false)
        pageViewController.methodsCalled = []
        await subject.receive(.navigateTo(indexOrig: 1, style: .appropriate))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == false)
    }

    @Test("showEnglish: calls card setEnglishHidden false")
    func showEnglish() async {
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let card = MockCardViewController(term: term1)
        await pageViewController.setViewControllers([card], direction: .forward, animated: false)
        await subject.receive(.showEnglish)
        #expect(card.methodsCalled == ["setEnglishHidden(_:)"])
        #expect(card.hidden == false)
    }

    @Test("viewControllerBefore: returns nil")
    func before() throws {
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
        subject.data = [term1, term2]
        let result = subject.pageViewController(pageViewController, viewControllerBefore: CardViewController(term: term2))
        #expect(result == nil)
    }

    @Test("viewControllerAfter: returns correct view controller")
    func after() throws {
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
        subject.data = [term1, term2]
        let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term1))
        #expect(result == nil)
    }

    @Test("page view controller supported orientations is landscape")
    func supported() {
        let result = subject.pageViewControllerSupportedInterfaceOrientations(UIPageViewController())
        #expect(result == [.landscape])
    }
}

