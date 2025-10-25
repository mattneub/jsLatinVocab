/// Messages from the presenter(s) to the processor.
enum LessonListAction: Equatable {
    case cancel
    case initialData
    case selectedLessonSection(String)
}
