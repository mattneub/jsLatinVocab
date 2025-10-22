/// Messages from the presenter(s) to the processor.
enum LessonListDrillAction: Equatable {
    case cancel
    case clear
    case drill([LessonSection])
    case initialData
}

struct LessonSection: Equatable {
    let lesson: String
    let section: String
}
