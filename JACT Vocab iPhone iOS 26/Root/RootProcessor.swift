import Foundation

/// The basic logic for the root module.
final class RootProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<Void, RootState>)?

    /// State to be presented by the presenter.
    var state = RootState() // TODO: it may be that this won't be needed and we'll use effect instead

    func receive(_ action: RootAction) async {
        switch action {
        case .initialInterface:
            state.terms = prepareTerms()
            state.initialTerm = state.terms[0] // TODO: eventually this can come from persistence
            await presenter?.present(state)
        }
    }

    /// Subroutine of `.initialInterface`. Fetch the data, transmute it into Terms, sort and number
    /// them, and return them.
    /// - Returns: The array of Terms, ready for display in the interface.
    func prepareTerms() -> [Term] {
        guard let path = services.bundle.path(forResource: "JactVocabUnicode", ofType: "txt") else {
            return []
        }
        guard let vocab = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        var terms = [Term]()
        let lines = vocab.components(separatedBy: "\n") // last one can be blank
        for (index, line) in lines.enumerated() {
            if line.count < 5 {
                break // ignore bogus empty lines
            }
            let term = Term(tabbedString: line, index: index)
            terms.append(term)
        }
        // sort into book order
        let sortFunctions = SwiftSortDescriptor<Term>.combine([
            SwiftSortDescriptor<Term>.sortFunction { $0.lessonSection },
            SwiftSortDescriptor<Term>.sortFunction { $0.beta },
            SwiftSortDescriptor<Term>.sortFunction { $0.indexOrig },
        ])
        terms.sort(by: sortFunctions)
        // renumber in current order
        var renumberedTerms = [Term]()
        for (index, var term) in terms.enumerated() {
            term.index = index
            renumberedTerms.append(term)
        }
        return renumberedTerms
    }
}
