@testable import Jact
import Testing
import Foundation

struct TermTests {
    @Test("tabbed string initializer fills out the properties as expected")
    func tabbedString() {
        do {
            let string = "ἄνθρωπος, ἡ\twoman\t3\tf (1gG)\tnoun (or whatever)"
            let subject = Term(tabbedString: string, index: 7)
            let expected = Term(
                latin: "ἄνθρωπος, ἡ",
                latinFirstWord: "ἄνθρωπος", // check; note the loss of comma
                beta: "ανθρωπος",
                english: "woman",
                lesson: "3",
                section: "f (1gG)",
                sectionFirstWord: "f", // check
                lessonSection: "03f", // check; note the zero padding
                part: "noun (or whatever)",
                partFirstWord: "noun", // check
                lessonSectionPartFirstWord: "03fnoun", // check
                indexOrig: 7, // check
                index: 7 // check
            )
            #expect(subject == expected)
        }
        do {
            let string = "γραφὴν γράφομαι\tindict X on a charge of Y (gen.)\t9\th\tidiom"
            let subject = Term(tabbedString: string, index: 7)
            #expect(subject.latinFirstWord == "γραφὴν γράφομαι") // replace no break space
            #expect(subject.beta == "γραφην γραφομαι") // internal space in beta is okay
        }
        do {
            let string = "τί;\twhat?\t1\td\tpronoun"
            let subject = Term(tabbedString: string, index: 7)
            #expect(subject.latinFirstWord == "τί") // handle greek question mark
        }
        do {
            let string = "Ἀθηναῖος, ὁ\tAthenian\t2\tb\tnoun"
            let subject = Term(tabbedString: string, index: 7)
            #expect(subject.beta == "αθηναιος") // lowercased, correctly decomposed
        }
        do {
            let string = "οὕτω(ς)\tthus, so, in this way\t2\td\tadverb"
            let subject = Term(tabbedString: string, index: 7)
            #expect(subject.beta == "ουτως") // removed parentheses
        }
    }
}

