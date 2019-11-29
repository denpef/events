import Foundation
import RxCocoa
import RxSwift

struct StorageKeys {
    var favorite = "favorite"
    var events = "events"
}

/// Local cache service
///
final class LocalStorage {
    struct Input {
        var update: PublishSubject<[Event]>
        var swapFavoriteMark: PublishSubject<Event>
        var cleanAll: AnyObserver<Void>
    }

    struct Output {
        var favoriteRefreshed: Observable<Void>
    }

    var input: Input
    var output: Output

    private var disposeBag = DisposeBag()

    func getEvents() -> [Event] {
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard

        if let data = defaults.object(forKey: keys.events) as? Data {
            if let event = try? decoder.decode([Event].self, from: data) {
                return event
            }
        }
        return []
    }

    func getFavorites() -> Set<Event> {
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard

        if let data = defaults.object(forKey: keys.favorite) as? Data {
            if let favorites = try? decoder.decode(Set<Event>.self, from: data) {
                return favorites
            }
        }
        return Set<Event>()
    }

    private let keys: StorageKeys

    init(with keys: StorageKeys = StorageKeys()) {
        self.keys = keys
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard

        let favoriteRefreshed = BehaviorSubject<Void>(value: ())

        let swapFavoriteMark = PublishSubject<Event>()
        swapFavoriteMark.subscribe(onNext: { event in
            if let data = defaults.object(forKey: keys.favorite) as? Data {
                if var favoriteSet = try? decoder.decode(Set<Event>.self, from: data) {
                    if favoriteSet.contains(event) {
                        favoriteSet.remove(event)
                    } else {
                        favoriteSet.insert(event)
                    }
                    if let encoded = try? encoder.encode(favoriteSet) {
                        defaults.set(encoded, forKey: keys.favorite)
                    }
                }
            } else {
                var favoriteSet = Set<Event>()
                favoriteSet.insert(event)
                if let encoded = try? encoder.encode(favoriteSet) {
                    defaults.set(encoded, forKey: keys.favorite)
                }
            }
            favoriteRefreshed.onNext(())
        }).disposed(by: disposeBag)

        let update = PublishSubject<[Event]>()
        update.subscribe(onNext: { events in
            if let encoded = try? encoder.encode(events) {
                defaults.set(encoded, forKey: keys.events)
            }
        }).disposed(by: disposeBag)

        let cleanAll = PublishSubject<Void>()
        cleanAll.subscribe(onNext: { _ in
            defaults.set(nil, forKey: keys.events)
            defaults.set(nil, forKey: keys.favorite)
        }).disposed(by: disposeBag)

        input = Input(update: update, swapFavoriteMark: swapFavoriteMark, cleanAll: cleanAll.asObserver())
        output = Output(favoriteRefreshed: favoriteRefreshed.asObservable())
    }
}
