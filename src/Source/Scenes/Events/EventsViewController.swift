import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class EventsViewController: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

    private let refreshControl = UIRefreshControl()

    var viewModel = EventsViewModel(eventService: EventService(api: API(networkProvider: NetworkProvider()),
                                                               storage: LocalStorage()))

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - Private

    private func setupUI() {
        refreshControl.tintColor = activityIndicator.tintColor
        tableView.refreshControl = refreshControl
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
    }

    private func bind() {
        viewModel.output.items
            .drive(tableView.rx.items(cellIdentifier: "EventCell", cellType: EventTableViewCell.self)) { [weak self] _, event, cell in
                guard let self = self else {
                    return
                }
                cell.titleLabel.text = event.title
                cell.subtitleLabel.text = event.start_time
                cell.favoriteButton.rx.tap.debug("fav tap")
                    .map { event }
                    .bind(to: self.viewModel.input.tapFavorite)
                    .disposed(by: cell.disposeBag)

            }.disposed(by: disposeBag)

        tableView.rx.modelSelected(Event.self)
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

        indicatorAnimating.drive(onNext: {
            print($0)
        }).disposed(by: disposeBag)

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
