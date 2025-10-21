enum RootEffect: Equatable {
    case englishHidden(Bool)
    case navigateTo(index: Int, style: NavigationStyle)
    case restoreLandscapeOrientation // see footnote on root view controller
}

/// Navigation styles.
enum NavigationStyle {
    case appropriate // Animate forward or reverse, based on relative indexes.
    case forward // Animate forward regardless of relative indexes.
    case noAnimation // Don't animate.
}
