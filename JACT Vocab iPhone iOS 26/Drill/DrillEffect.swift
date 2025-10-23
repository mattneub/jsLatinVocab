enum DrillEffect: Equatable {
    case done
    case navigateTo(indexOrig: Int, style: NavigationStyle)
    case progress(Float)
    case showEnglish
}
