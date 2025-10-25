import UIKit

/// Label with border, background color, and inset.
class BoundedLabel: UILabel {
    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            self.backgroundColor = UIColor.myPaler
            self.layer.borderWidth = 2.0
            self.layer.cornerRadius = 3.0
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 5, dy: 5).integral)
    }
}
