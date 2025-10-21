import Foundation

/// The basic logic for the all terms module.
final class AllTermsProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<Void, AllTermsState>)?

    /// Reference to the delegate, set by the coordinator at module creation time.
    weak var delegate: (any AllTermsDelegate)?

    /// State to be presented by the presenter.
    var state = AllTermsState()

    func receive(_ action: AllTermsAction) async {
        switch action {
        case .cancel:
            await delegate?.termChosen(indexOrig: -1) // no term
        case .initialInterface:
            await presenter?.present(state)
        case .termChosen(let indexOrig):
            await delegate?.termChosen(indexOrig: indexOrig)
        }
    }
}

protocol AllTermsDelegate: AnyObject {
    /// The user has asked to dismiss the all terms view controller, either by choosing an
    /// actual term (whose `indexOrig` is the argument) or by tapping the Cancel button
    /// (in which case `indexOrig` is a negative number). It is up to the delegate to respond,
    /// _including the dismissal of the presented view controller_.
    func termChosen(indexOrig: Int) async
}
