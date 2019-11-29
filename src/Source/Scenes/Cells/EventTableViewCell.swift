import RxCocoa
import RxSwift
import UIKit

/// Cell displays event info and favorite action marks
///
class EventTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!

    // MARK: - Properties

    var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    /// Fills the description text and the favorite trait
    /// - Parameter item: Event info and favorite mark
    func configure(with item: Item) {
        titleLabel.text = item.event.title
        subtitleLabel.text = item.event.dateDescription
        favoriteButton.setImage(item.image, tintColor: UIColor.Common.Green)
    }
}
