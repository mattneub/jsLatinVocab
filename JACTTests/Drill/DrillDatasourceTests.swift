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

    @Test("receive navigateTo: creates card of the correct class")
    func navigateToClass() async throws {
        let subject = DrillDatasource(pageViewController: pageViewController, processor: processor)
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        await subject.receive(.navigateTo(index: 0, style: .noAnimation))
        let card = try #require(pageViewController.viewControllers?.first as? DrillCardViewController)
        #expect(type(of: card) == DrillCardViewController.self)
        #expect(card.term == term)
    }

    @Test("receive navigateTo: given term index, creates card view controller and puts it in page view controller")
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
}

