import Foundation

/// The basic logic for the drill module.
final class DrillProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?
    
    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<DrillEffect, DrillState>)?
    
    /// State to be presented by the presenter.
    var state = DrillState()
    
    func receive(_ action: DrillAction) async {
        switch action {
        case .cancel:
            await coordinator?.dismiss()
        case .initialInterface:
            await presenter?.present(state)
            state.terms.shuffle()
            await navigateTo(index: 0, animated: false)
            state.originalCount = Float(state.terms.count)
        case .right:
            guard var index = state.terms.firstIndex(where: { $0.indexOrig == state.currentTermIndexOrig }) else {
                return
            }
            state.terms.remove(at: index)
            if state.terms.isEmpty { // done! got them all right; celebrate and we're out of here
                await presenter?.receive(.progress(0))
                await presenter?.receive(.done)
                try? await unlessTesting {
                    try? await Task.sleep(for: .seconds(0.4))
                }
                await coordinator?.dismiss()
            } else {
                if !state.terms.indices.contains(index) {
                    state.terms.shuffle()
                    index = 0
                }
                await navigateTo(index: index, animated: true)
                await presenter?.receive(.progress(Float(state.terms.count) / state.originalCount))
            }
        case .showEnglish:
            await presenter?.receive(.showEnglish)
        case .wrong:
            guard var index = state.terms.firstIndex(where: { $0.indexOrig == state.currentTermIndexOrig }) else {
                return
            }
            index += 1
            if !state.terms.indices.contains(index) {
                state.terms.shuffle()
                index = 0
            }
            await navigateTo(index: index, animated: true)
        }
    }
    
    /// Given an index into the terms array, tell the presenter to display that term.
    /// - Parameter index: An index into the terms array.
    func navigateTo(index: Int, animated: Bool) async {
        let indexOrig = state.terms[index].indexOrig
        await presenter?.receive(.navigateTo(indexOrig: indexOrig, style: animated ? .forward : .noAnimation))
        state.currentTermIndexOrig = indexOrig
    }
}
