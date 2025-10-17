/// Actions sent by presenter to processor.
enum RootAction: Equatable {
    case initialInterface
    case showInfo
    case tappedLabel(TappedLabel, currentTerm: Int)
    case toggleEnglish
}
