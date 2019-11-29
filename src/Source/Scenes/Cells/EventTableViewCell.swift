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
}
