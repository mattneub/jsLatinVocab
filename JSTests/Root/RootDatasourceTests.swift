@testable import JSLatin
import Testing
import UIKit

struct RootDatasourceTests {
    var subject: RootDatasource!
    let pageViewController = MockPageViewController()
    let processor = MockReceiver<RootAction>()

    init() {
        subject = RootDatasource(pageViewController: pageViewController, processor: processor)
        subject.cardClass = MockCardViewController.self
    }

    @Test("receive englishHidden: sets englishHidden, calls card setEnglishHidden")
    func englishHidden() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let card = MockCardViewController(term: term)
        await pageViewController.setViewControllers([card], direction: .forward, animated: false)
        await subject.receive(.englishHidden(true))
        #expect(subject.englishHidden == true)
        #expect(card.methodsCalled == ["setEnglishHidden(_:)"])
        #expect(card.hidden == true)
        await subject.receive(.englishHidden(false))
        #expect(subject.englishHidden == false)
        #expect(card.methodsCalled == ["setEnglishHidden(_:)", "setEnglishHidden(_:)"])
        #expect(card.hidden == false)
    }

    @Test("receive extraShowing: sets extraShowing, calls card setExtraShowing")
    func extraShowing() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let card = MockCardViewController(term: term)
        await pageViewController.setViewControllers([card], direction: .forward, animated: false)
        await subject.receive(.extraShowing(true))
        #expect(subject.extraShowing == true)
        #expect(card.methodsCalled == ["setExtraShowing(_:)"])
        #expect(card.showing == true)
        await subject.receive(.extraShowing(false))
        #expect(subject.extraShowing == false)
        #expect(card.methodsCalled == ["setExtraShowing(_:)", "setExtraShowing(_:)"])
        #expect(card.showing == false)
    }

    @Test("receive navigateTo: creates card of the correct class")
    func navigateToClass() async throws {
        let subject = RootDatasource(pageViewController: pageViewController, processor: processor)
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        await subject.receive(.navigateTo(index: 0, style: .noAnimation))
        let card = try #require(pageViewController.viewControllers?.first as? CardViewController)
        #expect(type(of: card) == CardViewController.self)
        #expect(card.term == term)
    }

    @Test("receive navigateTo: given term index, creates card view controller and puts it in pvc, sends navigated")
    func navigateTo() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        await subject.receive(.navigateTo(index: 0, style: .noAnimation))
        let card = try #require(pageViewController.viewControllers?.first as? MockCardViewController)
        #expect(card.term == term)
        #expect(card.processor === processor)
        #expect(card.methodsCalled == ["setEnglishHidden(_:)", "setExtraShowing(_:)"])
        #expect(card.hidden == false)
        #expect(processor.thingsReceived == [.navigated(indexOrig: 1)])
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
        await subject.receive(.navigateTo(index: 0, style: .noAnimation))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == false)
        pageViewController.methodsCalled = []
        await subject.receive(.navigateTo(index: 0, style: .forward))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == true)
        pageViewController.methodsCalled = []
        await subject.receive(.navigateTo(index: 1, style: .appropriate))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .forward)
        #expect(pageViewController.animated == true)
        pageViewController.methodsCalled = []
        await subject.receive(.navigateTo(index: 0, style: .appropriate))
        #expect(pageViewController.methodsCalled == ["setViewControllers(_:direction:animated:completion:)"])
        #expect(pageViewController.direction == .reverse)
        #expect(pageViewController.animated == true)
    }

    @Test("viewControllerBefore: returns correct view controller")
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
        do {
            let result = subject.pageViewController(pageViewController, viewControllerBefore: CardViewController(term: term2))
            let card = try #require(result as? MockCardViewController)
            #expect(card.term == term1)
            #expect(card.processor === processor)
            #expect(card.methodsCalled == ["setEnglishHidden(_:)", "setExtraShowing(_:)"])
            #expect(card.hidden == false)
        }
        do {
            let result = subject.pageViewController(pageViewController, viewControllerBefore: CardViewController(term: term1))
            #expect(result == nil)
        }
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
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term1))
            let card = try #require(result as? MockCardViewController)
            #expect(card.term == term2)
            #expect(card.processor === processor)
            #expect(card.methodsCalled == ["setEnglishHidden(_:)", "setExtraShowing(_:)"])
            #expect(card.hidden == false)
        }
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term2))
            #expect(result == nil)
        }
    }

    @Test("page view controller supported orientations is landscape")
    func supported() {
        let result = subject.pageViewControllerSupportedInterfaceOrientations(UIPageViewController())
        #expect(result == [.landscape])
    }

    @Test("didFinishAnimating: sends navigated")
    func didFinishAnimating() async {
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let card = MockCardViewController(term: term1)
        await pageViewController.setViewControllers([card], direction: .forward, animated: false)
        subject.pageViewController(pageViewController, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: true)
        #expect(processor.thingsReceived == [.navigated(indexOrig: 1)])
    }
}
