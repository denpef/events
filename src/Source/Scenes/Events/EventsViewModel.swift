import RxCocoa
import RxSwift

struct EventsViewModel {
    struct Input {
        let refreshItems: AnyObserver<Void>
        let selectedItem: AnyObserver<Item>
        let tapFavorite: AnyObserver<Event>
        let viewDidAppear: AnyObserver<Void>
    }

    struct Output {
        let items: Driver<[Item]>
        let error: Driver<String>
    }

    var input: Input
    var output: Output

    private var timer: Timer?
    private let disposeBag = DisposeBag()

    init(eventService: EventService) {
        let refreshEvents = BehaviorSubject<Void>(value: ())
        let error = eventService.output.networkError
            .map { _ in
                "Network error. Please try later"
            }

        let serverEvents: Observable<[Event]> = refreshEvents
            .flatMapLatest {
                eventService.output.serverEvents
            }

        let items: Driver<[Item]> = Observable.combineLatest(serverEvents, eventService.output.favorites) { events, favorites in
            events.sorted(by: >).map { Item(event: $0, isFavorite: favorites.contains($0)) }
        }.asDriver(onErrorJustReturn: [])

        let selectEvent = PublishSubject<Item>()
        selectEvent.subscribe(onNext: { item in
            OpenURLHelper.openLink(by: item.event.url)
        }).disposed(by: disposeBag)

        let viewDidAppear = PublishSubject<Void>()

        input = Input(refreshItems: refreshEvents.asObserver(),
                      selectedItem: selectEvent.asObserver(),
                      tapFavorite: eventService.input.swapFavoriteMark,
                      viewDidAppear: viewDidAppear.asObserver())

        output = Output(items: items,
                        error: error.asDriver(onErrorJustReturn: "Unknown error"))
    }
}
