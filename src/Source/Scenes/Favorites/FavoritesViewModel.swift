import Foundation
import RxCocoa
import RxSwift

/// Favorite screen buisness logic
///
struct FavoritesViewModel {
    struct Input {
        /// Tap favorite button action - swaping favorite mark
        let tapFavorite: AnyObserver<Event>
        /// Action handle cell item selection - open URL in browser
        let selectedItem: AnyObserver<Item>
    }

    struct Output {
        /// Favorite data source
        let items: Driver<[Item]>
    }

    var input: Input
    var output: Output

    // MARK: - Private properties

    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(with storage: LocalStorage) {
        let items = storage.output.favoriteRefreshed
            .map { storage.getFavorites().sorted(by: >).map { Item(event: $0, isFavorite: true) }
            }.asDriver(onErrorJustReturn: [])

        let selectEvent = PublishSubject<Item>()
        selectEvent.subscribe(onNext: { item in
            OpenURLHelper.shared.openLink(by: item.event.url)
        }).disposed(by: disposeBag)

        let tapFavorite: AnyObserver<Event> = storage.input.swapFavoriteMark.asObserver()

        input = Input(tapFavorite: tapFavorite,
                      selectedItem: selectEvent.asObserver())
        output = Output(items: items)
    }
}
