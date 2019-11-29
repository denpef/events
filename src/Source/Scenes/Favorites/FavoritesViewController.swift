import RxCocoa
import RxSwift
import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var viewModel: FavoritesViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        viewModel.output.items
            .drive(tableView.rx.items(cellIdentifier: "EventCell", cellType: EventTableViewCell.self)) { [weak self] _, item, cell in
                guard let self = self else {
                    return
                }
                cell.titleLabel.text = item.event.title
                cell.subtitleLabel.text = item.event.start_time
                cell.titleLabel.textColor = item.isFavorite ? UIColor.red : UIColor.black
                cell.favoriteButton.rx.tap
                    .map { item.event }
                    .bind(to: self.viewModel.input.tapFavorite)
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)

        tableView.rx.modelSelected(Item.self)
            .bind(to: viewModel.input.selectedItem)
            .disposed(by: disposeBag)
    }
}

extension FavoritesViewController: Configurable {
    func configure(with serviceLocator: ServiceContainerType) {
        viewModel = FavoritesViewModel(storage: serviceLocator.localStorage)
    }
}
