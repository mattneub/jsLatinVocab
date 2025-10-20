/// Actions sent by presenter to processor.
enum RootAction: Equatable {
    case initialInterface
    case showAllTerms
    case showInfo
    case showLessonList
    case tappedLabel(TappedLabel, currentTerm: Int)
    case toggleEnglish
}
