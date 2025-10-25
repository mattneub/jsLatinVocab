@testable import JSLatin
import Testing
import UIKit
import WaitWhile

struct CardViewControllerTests {
    @Test("initialize plus view did load sets the Term, populates the interface")
    func initializePlusViewDidLoad() throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let subject = CardViewController(term: term)
        #expect(subject.term.indexOrig == 1)
        subject.loadViewIfNeeded()
        #expect(subject.latin.text == "latin")
        #expect(subject.english.text == "english")
        #expect(subject.part.text == "part")
        #expect(subject.lesson.text == "lesson")
        #expect(subject.section.text == "section")
        do {
            let tapper = try #require(subject.lesson.gestureRecognizers?.first as? MyTapGestureRecognizer)
            #expect(tapper.target === subject)
            #expect(tapper.action == #selector(subject.tappedLabel))
        }
        do {
            let tapper = try #require(subject.section.gestureRecognizers?.first as? MyTapGestureRecognizer)
            #expect(tapper.target === subject)
            #expect(tapper.action == #selector(subject.tappedLabel))
        }
    }

    @Test("supported orientations is correct")
    func supported() {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = CardViewController(term: term)
        #expect(subject.supportedInterfaceOrientations == .landscape)
    }

    @Test("setEnglishHidden: set opacity of english label")
    func setEnglishHidden() {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = CardViewController(term: term)
        subject.loadViewIfNeeded()
        #expect(subject.english.layer.opacity == 1)
        subject.setEnglishHidden(true)
        #expect(subject.english.layer.opacity == 0)
        subject.setEnglishHidden(false)
        #expect(subject.english.layer.opacity == 1)
    }

    @Test("setExtraShowing: changes content of latin label if longer than one word")
    func setExtraShowing() {
        let term = Term(
            latin: "latin, rocks", latinFirstWord: "latin", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = CardViewController(term: term)
        subject.loadViewIfNeeded()
        #expect(subject.latin.text == "latin, rocks")
        subject.setExtraShowing(false)
        #expect(subject.latin.text == "latin …")
        subject.setExtraShowing(true)
        #expect(subject.latin.text == "latin, rocks")
    }

    @Test("tappedLabel: translates label into enum, sends tappedLabel with enum and term index")
    func tappedLabelLesson() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = CardViewController(term: term)
        let processor = MockReceiver<RootAction>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let tapper = try #require(subject.lesson.gestureRecognizers?.first as? UITapGestureRecognizer)
        subject.tappedLabel(tapper)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .tappedLabel(.lesson, currentTerm: 1))
    }

    @Test("tappedLabel: translates other label into enum, sends tappedLabel with enum and term index")
    func tappedLabelSection() async throws {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 1
        )
        let subject = CardViewController(term: term)
        let processor = MockReceiver<RootAction>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let tapper = try #require(subject.section.gestureRecognizers?.first as? UITapGestureRecognizer)
        subject.tappedLabel(tapper)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .tappedLabel(.section, currentTerm: 1))
    }
}
