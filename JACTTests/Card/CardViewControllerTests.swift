@testable import Jact
import Testing
import UIKit

struct CardViewControllerTests {
    @Test("initialize plus view did load sets the Term, populates the interface")
    func initializePlusViewDidLoad() {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 1
        )
        let subject = CardViewController(term: term)
        #expect(subject.term.indexOrig == 1)
        subject.loadViewIfNeeded()
        #expect(subject.latin.text == "latin")
        #expect(subject.english.text == "english")
        #expect(subject.part.text == "part")
        #expect(subject.lesson.text == "lesson")
        #expect(subject.section.text == "section")
    }
}
