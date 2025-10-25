/// Messages from the presenter(s) to the processor.
enum LessonListDrillAction: Equatable {
    case cancel
    case clear
    case drill // the _user_ has tapped the drill button
    case drillUsing([LessonSection]) // the _datasource_ is providing the data to drill
    case initialData
}

struct LessonSection: Equatable {
    let lesson: String
    let section: String
}
