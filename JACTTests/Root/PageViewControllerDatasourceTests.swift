@testable import Jact
import Testing
import UIKit

struct PageViewControllerDatasourceTests {
    @Test("receive navigateTo: given term index, creates card view controller and puts it in page view controller")
    func createInitialInterface() async throws {
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource(pageViewController: pageViewController, processor: nil)
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        subject.data = [term]
        let processor = MockReceiver<RootAction>()
        subject.processor = processor
        await subject.receive(.navigateTo(index: 0, animated: false))
        let card = try #require(pageViewController.viewControllers?.first as? CardViewController)
        #expect(card.term == term)
        #expect(card.processor === processor)
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
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource(pageViewController: pageViewController, processor: nil)
        subject.data = [term1, term2]
        let processor = MockReceiver<RootAction>()
        subject.processor = processor
        do {
            let result = subject.pageViewController(pageViewController, viewControllerBefore: CardViewController(term: term2))
            let card = try #require(result as? CardViewController)
            #expect(card.term == term1)
            #expect(card.processor === processor)
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
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource(pageViewController: pageViewController, processor: nil)
        subject.data = [term1, term2]
        let processor = MockReceiver<RootAction>()
        subject.processor = processor
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term1))
            let card = try #require(result as? CardViewController)
            #expect(card.term == term2)
            #expect(card.processor === processor)
        }
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term2))
            #expect(result == nil)
        }
    }
}
