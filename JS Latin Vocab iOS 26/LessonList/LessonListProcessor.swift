import Foundation

/// The basic logic for the lesson list module.
final class LessonListProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<Void, LessonListState>)?

    /// Reference to the delegate, set by the coordinator at module creation time.
    weak var delegate: (any LessonListDelegate)?

    /// State to be presented by the presenter.
    var state = LessonListState()

    func receive(_ action: LessonListAction) async {
        switch action {
        case .cancel:
            await coordinator?.dismiss()
        case .initialData:
            await presenter?.present(state) // State has been configured by the coordinator.
        case .selectedLessonSection(let lessonSection):
            await coordinator?.dismiss()
            if let index = state.terms.firstIndex(where: { $0.lesson + $0.sectionFirstWord == lessonSection }) {
                await delegate?.navigateTo(index: index)
            }
        }
    }
}

protocol LessonListDelegate: AnyObject {
    func navigateTo(index: Int) async
}
