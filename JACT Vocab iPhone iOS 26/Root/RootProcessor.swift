import Foundation

/// The basic logic for the root module.
final class RootProcessor: Processor {
    /// Reference to the coordinator, set by the coordinator at module creation time.
    weak var coordinator: (any RootCoordinatorType)?

    /// Reference to the presenter, set by the coordinator at module creation time.
    weak var presenter: (any ReceiverPresenter<RootEffect, RootState>)?

    /// State to be presented by the presenter.
    var state = RootState() // TODO: it may be that this won't be needed and we'll use effect instead

    func receive(_ action: RootAction) async {
        switch action {
        case .initialInterface:
            state.terms = prepareTerms()
            let initialIndex = 0 // TODO: eventually this can come from persistence
            await presenter?.present(state)
            let englishHidden = services.persistence.isEnglishHidden()
            await presenter?.receive(.englishHidden(englishHidden))
            await presenter?.receive(.navigateTo(index: initialIndex, animated: false))
        case .showInfo:
            coordinator?.showInfo()
        case .tappedLabel(let label, let currentTermIndex): // navigate by category
            // convert label tapped to Term property to be consulted
            let getter: KeyPath<Term, String> = switch label {
            case .lesson: \.lesson
            case .section: \.lessonSection
            }
            let currentValue = state.terms[currentTermIndex][keyPath: getter]
            // first, try terms _after_ current term
            if let index = state.terms[(currentTermIndex + 1)...].firstIndex(where: {
                $0[keyPath: getter] != currentValue
            }) {
                await presenter?.receive(.navigateTo(index: index, animated: true))
                return
            }
            // if that didn't work, try terms _before_ current term
            if let index = state.terms[..<currentTermIndex].firstIndex(where: {
                $0[keyPath: getter] != currentValue
            }) {
                await presenter?.receive(.navigateTo(index: index, animated: true))
                return
            }
        case .toggleEnglish:
            let hidden = !services.persistence.isEnglishHidden()
            services.persistence.setEnglishHidden(hidden)
            await presenter?.receive(.englishHidden(hidden))
        }
    }

    /// Subroutine of `.initialInterface`. Fetch the data, transmute it into Terms, sort and number
    /// them, and return them.
    /// - Returns: The array of Terms, ready for display in the interface.
    func prepareTerms() -> [Term] {
        guard let path = services.bundle.path(forResource: "JactVocabUnicode", ofType: "txt"),
              let vocab = try? String(contentsOfFile: path, encoding: .utf8) else {
            return []
        }
        // we're going to sort into book order
        let sortFunctions = SwiftSortDescriptor<Term>.combine([
            SwiftSortDescriptor<Term>.sortFunction { $0.lessonSection },
            SwiftSortDescriptor<Term>.sortFunction { $0.beta },
            SwiftSortDescriptor<Term>.sortFunction { $0.indexOrig },
        ])
        let terms = vocab.components(separatedBy: "\n")
            .filter { $0.count > 5 } // remove "blank" lines
            .enumerated() // use index within unsorted list as original index
            .map { index, line -> Term in
                Term(tabbedString: line, index: index)
            }.sorted(by: sortFunctions)
            .enumerated() // use index within sorted list as index
            .map { index, term in
                var term = term
                term.index = index
                return term
            }
        return terms
    }
}
