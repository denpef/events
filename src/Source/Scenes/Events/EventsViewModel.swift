import RxCocoa
import RxSwift

struct EventsViewModel {
    struct Input {
        let refreshItems: PublishSubject<Void>
        let selectedItem: AnyObserver<Event>
        let tapFavorite: AnyObserver<Event>
    }

    struct Output {
        let events: Driver<[Event]>
        let error: Driver<String>
    }

    var input: Input
    var output: Output

    private var eventService: EventService
    private let disposeBag = DisposeBag()

    init(eventService: EventService) {
        self.eventService = eventService

        let events: Driver<[Event]> = self.eventService.output.serverEvents
            .map { $0.events.event }
            .asDriver(onErrorJustReturn: [])

        let updateFavoriteMark = PublishSubject<Event>()
        updateFavoriteMark
            .bind(to: eventService.input.swapFavoriteMark)
            .disposed(by: disposeBag)

        let selectEvent = PublishSubject<Event>()
        selectEvent.subscribe(onNext: { event in
            OpenURLHelper.openLink(by: event.url)
        }).disposed(by: disposeBag)

        let refreshEvents = PublishSubject<Void>()
        refreshEvents
            .bind(to: eventService.input.refreshEvents)
            .disposed(by: disposeBag)

        let error = PublishSubject<String>()

        input = Input(refreshItems: refreshEvents,
                      selectedItem: selectEvent.asObserver(),
                      tapFavorite: updateFavoriteMark.asObserver())

        output = Output(events: events,
                        error: error.asDriver(onErrorJustReturn: "Unknown error"))
    }
}
