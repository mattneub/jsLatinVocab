import Foundation

/// The basic logic for the lesson list module.
final class LessonListDrillProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<LessonListDrillEffect, LessonListDrillState>)?

    /// State to be presented by the presenter.
    var state = LessonListDrillState()

    func receive(_ action: LessonListDrillAction) async {
        switch action {
        case .cancel:
            await coordinator?.dismiss()
        case .initialData:
            await presenter?.present(state) // State has been configured by the coordinator.
        case .clear:
            await presenter?.receive(.clear)
        }
    }
}
