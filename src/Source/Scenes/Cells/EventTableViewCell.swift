import RxCocoa
import RxSwift
import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func configure(with item: Item) {
        titleLabel.text = item.event.title
        subtitleLabel.text = item.event.dateDescription
        favoriteButton.setImage(item.image, tintColor: UIColor.Common.Green)
    }
}
