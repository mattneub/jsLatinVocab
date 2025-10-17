import Foundation

final class InfoProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<Void, InfoState>)?

    /// State to be presented by the presenter.
    var state = InfoState()

    func receive(_ action: InfoAction) async {
        switch action {
        case .done:
            coordinator?.dismiss()
        case .initialInterface:
            if let path = services.bundle.path(forResource: "jactVocabHelp", ofType: "html"),
               let content = try? String(contentsOfFile: path, encoding: .utf8) {
                state.url = URL(fileURLWithPath: path)
                state.content = content
                await presenter?.present(state)
            }
        }
    }
}
