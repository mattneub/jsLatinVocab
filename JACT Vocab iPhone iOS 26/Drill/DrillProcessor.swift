import Foundation

/// The basic logic for the drill module.
final class DrillProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?
    
    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<DrillEffect, DrillState>)?
    
    /// State to be presented by the presenter.
    var state = DrillState() // TODO: it may be that this won't be needed and we'll use effect instead
    
    func receive(_ action: DrillAction) async {
        switch action {
        case .initialInterface:
            await presenter?.present(state)
            // TODO: some kind of shuffle goes somewhere in here
            await presenter?.receive(.navigateTo(index: 0, style: .noAnimation))
        }
    }
}
