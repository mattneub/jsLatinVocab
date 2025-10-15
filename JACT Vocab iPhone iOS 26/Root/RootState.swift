struct RootState: Equatable {
    var initialTerm: Term? // TODO: This seems like a really bad way to communicate "initial" situation.
    var terms = [Term]()
}
