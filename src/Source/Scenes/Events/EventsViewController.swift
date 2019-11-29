import RxCocoa
import RxDataSources
import RxSwift
import UIKit

struct Item {
    let event: Event
    let isFavorite: Bool
}

class EventsViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

    private let refreshControl = UIRefreshControl()

    private var viewModel: EventsViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.input.viewDidAppear.on(.next(()))
    }

    // MARK: - Private

    private func setupUI() {
        refreshControl.tintColor = activityIndicator.tintColor
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
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

        tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshItems)
            .disposed(by: disposeBag)

        viewModel.output.error
            .drive(onNext: {
                self.showAlert(message: $0)
            }).disposed(by: disposeBag)

        let indicatorAnimating = Driver.merge(viewModel.output.error.map { _ in false },
                                              viewModel.output.items.map { _ in false })

        indicatorAnimating
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        indicatorAnimating
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    }

    private func showAlert(message: String?) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension EventsViewController: Configurable {
    func configure(with serviceLocator: ServiceContainerType) {
        viewModel = EventsViewModel(eventService: serviceLocator.eventService)
    }
}
