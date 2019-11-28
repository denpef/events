import RxSwift

final class EventService {
    struct Input {
        let refreshEvents: AnyObserver<Void>
        let swapFavoriteMark: AnyObserver<Event>
    }

    struct Output {
        let serverEvents: Observable<EventsData>
    }

    var input: EventService.Input
    var output: EventService.Output

    private let api: API
    private let disposeBag = DisposeBag()

    init(api: API) {
        self.api = api

        let refreshEvents = BehaviorSubject<Void>(value: ())

        let swapFavoriteMark = PublishSubject<Event>()
        swapFavoriteMark.subscribe(onNext: { event in
            var favoriteSet = UserDefaults.standard.object(forKey: "favorite") as? Set<Event> ?? Set<Event>()
            if favoriteSet.contains(event) {
                favoriteSet.remove(event)
            } else {
                favoriteSet.insert(event)
            }
            UserDefaults.standard.set(favoriteSet, forKey: "favorite")
        }).disposed(by: disposeBag)

        let serverEvents = refreshEvents.flatMapLatest { api.getEvents() }

        input = Input(refreshEvents: refreshEvents.asObserver(),
                      swapFavoriteMark: swapFavoriteMark.asObserver())
        output = Output(serverEvents: serverEvents)
    }

    private var favorite: Set<Event> {
        return UserDefaults.standard.object(forKey: "favorite") as? Set<Event> ?? Set<Event>()
    }
}
