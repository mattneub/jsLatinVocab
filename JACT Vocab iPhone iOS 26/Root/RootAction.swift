/// Actions sent by presenter to processor.
enum RootAction: Equatable {
    case initialInterface
    case tappedLabel(TappedLabel, currentTerm: Int)
}
