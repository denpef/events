import RxSwift

final class EventService {
    struct Input {
        let swapFavoriteMark: AnyObserver<Event>
    }

    struct Output {
        let serverEvents: Observable<[Event]>
        let networkError: Observable<Error>
    }

    var input: Input
    var output: Output

    private let api: API
    private let disposeBag = DisposeBag()

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

        input = Input(swapFavoriteMark: storage.input.swapFavoriteMark.asObserver())

        output = Output(serverEvents: serverEvents,
                        networkError: networkError.asObservable())
    }
}
