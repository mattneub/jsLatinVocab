/// Actions sent by presenter to processor.
enum RootAction: Equatable {
    case initialInterface
    case navigated(indexOrig: Int)
    case showAllTerms
    case showInfo
    case showLessonList
    case showLessonListDrill
    case tappedLabel(TappedLabel, currentTerm: Int)
    case toggleEnglish
    case toggleExtra
}
