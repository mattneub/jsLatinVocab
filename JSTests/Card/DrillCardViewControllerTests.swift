@testable import JSLatin
import Testing
import UIKit
import WaitWhile

struct DrillCardViewControllerTests {
    @Test("initialize plus view did load sets the Term, populates the interface")
    func initializePlusViewDidLoad() throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let subject = DrillCardViewController(term: term)
        #expect(subject.term.indexOrig == 1)
        subject.loadViewIfNeeded()
        #expect(subject.latin.text == "latin")
        #expect(subject.english.text == "english")
        #expect(subject.part.text == "part")
        #expect(subject.lesson.text == "lesson")
        #expect(subject.section.text == "section")
        #expect(subject.lesson.gestureRecognizers == [])
        #expect(subject.section.gestureRecognizers == [])
    }

    @Test("supported orientations is correct")
    func supported() {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = DrillCardViewController(term: term)
        #expect(subject.supportedInterfaceOrientations == .landscape)
    }

    @Test("setEnglishHidden: set opacity of english label")
    func setEnglishHidden() {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = DrillCardViewController(term: term)
        subject.loadViewIfNeeded()
        #expect(subject.english.layer.opacity == 1)
        subject.setEnglishHidden(true)
        #expect(subject.english.layer.opacity == 0)
        subject.setEnglishHidden(false)
        #expect(subject.english.layer.opacity == 1)
    }
}
