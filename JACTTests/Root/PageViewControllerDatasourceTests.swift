@testable import Jact
import Testing
import UIKit

struct PageViewControllerDatasourceTests {
    @Test("createInitialInterface: given term, creates card view controller and puts it in page view controller")
    func createInitialInterface() throws {
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource<RootAction>(pageViewController: pageViewController, processor: nil)
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 1
        )
        subject.createInitialInterface(term: term)
        let card = try #require(pageViewController.viewControllers?.first as? CardViewController)
        #expect(card.term == term)
    }

    @Test("viewControllerBefore: returns correct view controller")
    func before() throws {
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 1
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 2
        )
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource<RootAction>(pageViewController: pageViewController, processor: nil)
        subject.data = [term1, term2]
        do {
            let result = subject.pageViewController(pageViewController, viewControllerBefore: CardViewController(term: term2))
            let card = try #require(result as? CardViewController)
            #expect(card.term == term1)
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
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 1
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 2
        )
        let pageViewController = UIPageViewController()
        let subject = PageViewControllerDatasource<RootAction>(pageViewController: pageViewController, processor: nil)
        subject.data = [term1, term2]
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term1))
            let card = try #require(result as? CardViewController)
            #expect(card.term == term2)
        }
        do {
            let result = subject.pageViewController(pageViewController, viewControllerAfter: CardViewController(term: term2))
            #expect(result == nil)
        }
    }
}
