import UIKit

/// View controller that presents its view as a "card" in the page view controller.
final class CardViewController: UIViewController {
    /// Reference to the processor, so that we can inform it of taps on labels (to sort).
    weak var processor: (any Receiver<RootAction>)?

    /// The Term with which we were initialized. We need to hold this because (1) we cannot
    /// configure the labels until later (`viewDidLoad`), and (2) we need a way of asking this
    /// instance which Term it represents (by way of its `indexOrig`).
    let term: Term

    @IBOutlet var latin: UILabel!
    @IBOutlet var english: UILabel!
    @IBOutlet var part: UILabel!
    @IBOutlet var lesson: UILabel!
    @IBOutlet var section: UILabel!

    init(term: Term) {
        self.term = term
        super.init(nibName: "Card", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        latin.text = term.latin
        english.text = term.english
        part.text = term.part
        lesson.text = term.lesson
        section.text = term.section
        // two labels are tappable to navigate
        do {
            let tapper = MyTapGestureRecognizer(target: self, action: #selector(tappedLabel))
            lesson.addGestureRecognizer(tapper)
            lesson.isUserInteractionEnabled = true
        }
        do {
            let tapper = MyTapGestureRecognizer(target: self, action: #selector(tappedLabel))
            section.addGestureRecognizer(tapper)
            section.isUserInteractionEnabled = true
        }
    }

    @objc func tappedLabel(_ tapper: UITapGestureRecognizer) {
        guard let label = tapper.view as? UILabel else {
            return
        }
        let tappedLabel: TappedLabel = switch label {
        case lesson: .lesson
        case section: .section
        default: .lesson // shouldn't happen
        }
        Task {
            await processor?.receive(.tappedLabel(tappedLabel, currentTerm: term.index))
        }
    }
}

enum TappedLabel {
    case lesson
    case section
}

