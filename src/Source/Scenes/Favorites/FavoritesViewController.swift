import RxCocoa
import RxSwift
import UIKit

/// Favorites screen
///
class FavoritesViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var tableView: UITableView!

    // MARK: - Private properties

    private var viewModel: FavoritesViewModel!
    private let disposeBag = DisposeBag()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - Private methods

    private func setupUI() {
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventCell")
    }

    private func bind() {
        viewModel.output.items
            .drive(tableView.rx.items(cellIdentifier: "EventCell", cellType: EventTableViewCell.self)) { [weak self] _, item, cell in
                guard let self = self else {
                    return
                }
                cell.configure(with: item)
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
    /// Configure viewModel
    /// - Parameter serviceContainer: Service container
    func configure(with serviceContainer: ServiceContainerType) {
        viewModel = FavoritesViewModel(with: serviceContainer.localStorage)
    }
}
