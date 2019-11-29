import RxSwift

final class EventService {
    struct Input {
        let swapFavoriteMark: AnyObserver<Event>
    }

    struct Output {
        let serverEvents: Observable<[Event]>
        let networkError: Observable<Error>
        let favorites: Observable<Set<Event>>
    }

    var input: Input
    var output: Output

    private let api: API
    private let disposeBag = DisposeBag()

    init(api: API, storage: LocalStorage) {
        self.api = api

        let networkError = PublishSubject<Error>()

//        Observable.combineLatest(api.getEvents(), storage.output.favoriteRefreshed) map {

        let serverEvents = api.getEvents()
            .map { $0.events.event }
            .catchError { error -> Observable<[Event]> in
                networkError.on(.next(error))
                return Observable.of(storage.getEvents())
            }

        serverEvents
            .bind(to: storage.input.update)
            .disposed(by: disposeBag)

        let favorites: Observable<Set<Event>> = storage.output.favoriteRefreshed
            .map { storage.getFavorites() }

        input = Input(swapFavoriteMark: storage.input.swapFavoriteMark.asObserver())

        output = Output(serverEvents: serverEvents,
                        networkError: networkError.asObservable(),
                        favorites: favorites)
    }
}
