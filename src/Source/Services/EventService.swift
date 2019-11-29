import RxSwift

/// The service provides the ability to work with a list of events
final class EventService {
    // MARK: - Nested types

    struct Input {
        /// Swaping favorite mark (true/false)
        let swapFavoriteMark: AnyObserver<Event>
    }

    struct Output {
        /// Decoded server request data
        let serverEvents: Observable<[Event]>
        /// Handle network error
        let networkError: Observable<Error>
        /// Swaping favorite mark (true/false)
        let favorites: Observable<Set<Event>>
    }

    // MARK: - Properties

    var input: Input
    var output: Output

    // MARK: - Private properties

    private let api: API
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(api: API, storage: LocalStorage) {
        self.api = api

        let networkError = PublishSubject<Error>()

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
