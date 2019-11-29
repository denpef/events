import Foundation
import RxCocoa
import RxSwift

/// Keys to save data in UserDefaults
struct StorageKeys {
    var favorite = "favorite"
    var events = "events"
}

/// Local cache service
/// Saves data in UserDefaults
final class LocalStorage {
    // MARK: - Nested types

    struct Input {
        /// Update data by events key
        var update: PublishSubject<[Event]>
        /// Swapping favorite mark (true/false)
        var swapFavoriteMark: PublishSubject<Event>
        /// Clean all cache - useful in testing
        var cleanAll: AnyObserver<Void>
    }

    struct Output {
        /// Favorite data was refreshed
        var favoriteRefreshed: Observable<Void>
    }

    // MARK: - Pproperties

    var input: Input
    var output: Output

    // MARK: - Private properties

    private var disposeBag = DisposeBag()
    private let keys: StorageKeys

    // MARK: - Init

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

    // MARK: - Methods

    /// Returns current cached event list
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

    /// Returns current favorite list
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
}
