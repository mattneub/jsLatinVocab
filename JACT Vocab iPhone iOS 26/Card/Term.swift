import Foundation

/// A single entry (line) in our original data. This is what each "card" displays.
/// The basic data are `latin` (meaning Greek), `english`, `lesson`, `section`, and `part`;
/// other properties are calculated from these, except for `indexOrig` which functions as an id,
/// and `index` which can vary depending on sort order.
///
/// You could argue that the calculated properties could be computed properties rather than
/// stored properties. But this seems pointless, since they cannot vary, so we may as well
/// calculate them all up front.
struct Term: Equatable {
    let latin: String
    let latinFirstWord: String // the vocab keeps stuff together as first word by using a joiner (nobreak space)
    let beta: String // for alphabetical order, based on first word; see `beta2`
    let english: String
    let lesson: String
    let section: String
    let sectionFirstWord: String // section with ancillary info stripped off, as with "f (1gG)"
    let lessonSection: String // sortable string numerically padded, e.g. "03f"
    let part: String // meaning "part of speech"
    let partFirstWord: String
    let lessonSectionPartFirstWord: String // even better navigation logic, lessonSection + partFirstWord
    let indexOrig: Int // order from the raw data; functions as unique id
    var index = -1 // order at any given moment
}

extension Term {
    init(tabbedString: String, index: Int) {
        let components = tabbedString.components(separatedBy: "\t")
        assert(components.count == 5, "bad vocab item, not 5 fields \(components)")
        // actual data
        self.latin = components[0]
        self.english = components[1]
        self.lesson = components[2]
        self.section = components[3]
        self.part = components[4]
        // calculated properties
        self.latinFirstWord = Term.firstWord(of: self.latin)
        self.beta = Term.beta2(self.latinFirstWord)
        self.sectionFirstWord = Term.firstWord(of: self.section)
        self.lessonSection = String(
            format: "%02i%@",
            (self.lesson as NSString).intValue, // because it scans from start and stops at a nondigit
            self.sectionFirstWord
        )
        self.partFirstWord = Term.firstWord(of: self.part)
        self.lessonSectionPartFirstWord = self.lessonSection + self.partFirstWord
        self.indexOrig = index
        self.index = index
    }

    /// Extract the first word from the text, where a "word" is a stretch of characters followed
    /// by a space. The text might contains a no-break space as a joiner to protect it from being
    /// broken up, but now that we have obeyed that injunction we can also turn that no-break
    /// space into a normal space within the result. If the last character is comma, colon, or
    /// Greek question mark, strip it off.
    /// - Parameter text: The text from which to extract the first word.
    /// - Returns: The first "word" of the original text.
    static func firstWord(of text: String) -> String {
        var word = text.components(separatedBy: " ")[0]
        word = word.replacingOccurrences(of:"\u{00A0}", with: " ")
        if [",", ";", ";"].contains(word.suffix(1)) {
            word = String(word.dropLast())
        }
        return word
    }
    
    /// Simplify into text without diacritics for pure sortability. To do so,
    /// we use "compatibility" rather than "canonical" in order to decompose
    /// fully initial prevocalic accent marks. We then lowercase, strip out everything that is not
    /// an alphabetic letter, and trim off leading and trailing spaces.
    /// - Parameter text: The original text, expected to be Greek.
    /// - Returns: The transliterated sortable equivalent text.
    static func beta2(_ text: String) -> String {
        var result = text
        // use "compatibility" rather than "canonical" in order to decompose fully initial prevocalic accent marks
        result = result.decomposedStringWithCompatibilityMapping.lowercased() // decompose; lowercase
        result = result.components(separatedBy: .nonBaseCharacters).joined() // remove the diacritics
        result = result.components(separatedBy: .punctuationCharacters).joined() // remove punctuation
        // result = result.replacingOccurrences(of: "v", with: "u") // Latin only
        result = result.trimmingCharacters(in: CharacterSet(charactersIn: " ")) // trim spaces
        return result
    }
}
