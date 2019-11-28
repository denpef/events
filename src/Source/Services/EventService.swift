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

        let refreshEvents = PublishSubject<Void>()

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

        let serverEvents = self.api.getEvents()

//        refreshEvents.subscribe(onNext: {
//            serverEvents = api.getEvents()
//        }).disposed(by: disposeBag)

        let asdaskjhdhjasgkfdhj = Observable.merge(serverEvents, refreshEvents.flatMapLatest { api.getEvents() })

        input = Input(refreshEvents: refreshEvents.asObserver(),
                      swapFavoriteMark: swapFavoriteMark.asObserver())
        output = Output(serverEvents: asdaskjhdhjasgkfdhj)
    }

    private var favorite: Set<Event> {
        return UserDefaults.standard.object(forKey: "favorite") as? Set<Event> ?? Set<Event>()
    }
}
