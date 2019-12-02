import RxCocoa
import RxSwift

/// Events screen buisness logic
///
struct EventsViewModel {
    // MARK: - Nested types

    struct Input {
        /// Reload action for data source
        let refreshItems: AnyObserver<Void>
        /// Action handle cell item selection - open URL in browser
        let selectedItem: AnyObserver<Item>
        /// Tap favorite button action - swaping favorite mark
        let tapFavorite: AnyObserver<Event>
    }

    struct Output {
        /// Events data source
        let items: Driver<[Item]>
        /// Server error handling
        let error: Driver<String>
        /// Timer execution signal
        let timerExecution: Observable<Void>
    }

    // MARK: - Properties

    var input: Input
    var output: Output

    // MARK: - Private properties

    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(with eventService: EventService, timerPeriod: Int = 3600) {
        let refreshEvents = PublishSubject<Void>()
        let error = eventService.output.networkError
            .map { _ in
                "Network error. Please try later"
            }

        let serverEvents: Observable<[Event]> = refreshEvents
            .flatMapLatest {
                eventService.output.serverEvents
            }

        let items: Driver<[Item]> = Observable
            .combineLatest(serverEvents, eventService.output.favorites) { events, favorites in
                events.sorted(by: >).map { Item(event: $0, isFavorite: favorites.contains($0)) }
            }.asDriver(onErrorJustReturn: [])

        let selectEvent = PublishSubject<Item>()
        selectEvent.subscribe(onNext: { item in
            OpenURLHelper.shared.openLink(by: item.event.url)
        }).disposed(by: disposeBag)

        let timeInterval = DispatchTimeInterval.seconds(timerPeriod)
        let timerExecution = Observable<Int>
            .timer(timeInterval, period: timeInterval, scheduler: MainScheduler.instance)
            .map { _ in }

        timerExecution.bind(to: refreshEvents)
            .disposed(by: disposeBag)

        input = Input(refreshItems: refreshEvents.asObserver(),
                      selectedItem: selectEvent.asObserver(),
                      tapFavorite: eventService.input.swapFavoriteMark)

        output = Output(items: items,
                        error: error.asDriver(onErrorJustReturn: "Unknown error"),
                        timerExecution: timerExecution)
    }
}
