import UIKit

/// Cell that reflects its selected state with a checkmark image. It seems silly that we have
/// to do this, but Apple has not given us an image transformer method that will change the image
/// based on the cell's state.
final class LessonListDrillCell: UICollectionViewListCell {
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        backgroundConfiguration?.image = state.isSelected ? UIImage.checkmark(ofSize: bounds.size) : nil
    }
}
