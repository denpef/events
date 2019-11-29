import Foundation
import RxCocoa
import RxSwift

struct FavoritesViewModel {
    struct Input {
        let tapFavorite: AnyObserver<Event>
        let selectedItem: AnyObserver<Item>
    }

    struct Output {
        let items: Driver<[Item]>
    }

    var input: Input
    var output: Output

    private let disposeBag = DisposeBag()

    init(storage: LocalStorage) {
        let items = storage.output.favoriteRefreshed
            .map { storage.getFavorites().sorted(by: >).map { Item(event: $0, isFavorite: true) }
            }.asDriver(onErrorJustReturn: [])

        let selectEvent = PublishSubject<Item>()
        selectEvent.subscribe(onNext: { item in
            OpenURLHelper.openLink(by: item.event.url)
        }).disposed(by: disposeBag)

        let tapFavorite: AnyObserver<Event> = storage.input.swapFavoriteMark.asObserver()

        input = Input(tapFavorite: tapFavorite,
                      selectedItem: selectEvent.asObserver())
        output = Output(items: items)
    }
}
