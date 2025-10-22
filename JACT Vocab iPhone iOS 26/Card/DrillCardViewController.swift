import UIKit

/// Reduced version of CardViewController. Labels are not tappable.
final class DrillCardViewController: CardViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for gestureRecognizer in (lesson.gestureRecognizers ?? []) {
            lesson.removeGestureRecognizer(gestureRecognizer)
        }
        for gestureRecognizer in (section.gestureRecognizers ?? []) {
            section.removeGestureRecognizer(gestureRecognizer)
        }
    }

}
