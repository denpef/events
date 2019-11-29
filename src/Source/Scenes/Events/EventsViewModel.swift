import RxCocoa
import RxSwift

struct EventsViewModel {
    struct Input {
        let refreshItems: AnyObserver<Void>
        let selectedItem: AnyObserver<Event>
        let tapFavorite: AnyObserver<Event>
    }

    struct Output {
        let items: Driver<[Event]>
        let error: Driver<String>
    }

    var input: Input
    var output: Output

    private let disposeBag = DisposeBag()

    init(eventService: EventService) {
        let refreshEvents = BehaviorSubject<Void>(value: ())
        let error = eventService.output.networkError
            .map { _ in
                "Network error. Please try later"
            }

        let serverIvents: Observable<[Event]> = refreshEvents
            .flatMapLatest {
                eventService.output.serverEvents
            }

        let items: Driver<[Event]> = serverIvents.asDriver(onErrorJustReturn: [])

//        serverIvents.subscribe(onNext: { newEventList in
//            storage.input.update.onNext(newEventList)
//        }).disposed(by: disposeBag)

        let updateFavoriteMark = PublishSubject<Event>()
//        updateFavoriteMark
//            .bind(to: storage.input.swapFavoriteMark)
//            .disposed(by: disposeBag)

        let selectEvent = PublishSubject<Event>()
        selectEvent.subscribe(onNext: { event in
            OpenURLHelper.openLink(by: event.url)
        }).disposed(by: disposeBag)

        input = Input(refreshItems: refreshEvents.asObserver(),
                      selectedItem: selectEvent.asObserver(),
                      tapFavorite: updateFavoriteMark.asObserver())

        output = Output(items: items, // .asDriver(onErrorJustReturn: []),
                        error: error.asDriver(onErrorJustReturn: "Unknown error"))
    }
}
