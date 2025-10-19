enum RootEffect: Equatable {
    case englishHidden(Bool)
    case navigateTo(index: Int, style: NavigationStyle)
}

/// Navigation styles.
enum NavigationStyle {
    case appropriate // Animate forward or reverse, based on relative indexes.
    case forward // Animate forward regardless of relative indexes.
    case noAnimation // Don't animate.
}
