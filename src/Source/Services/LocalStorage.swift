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
    }

//    struct Output {
//        var favorite: Observable<Set<Event>>
//        var events: Observable<[Event]>
//    }

    var input: Input
//    var output: Output

    private var disposeBag = DisposeBag()

    func getEvents() -> [Event] {
        let encoder = JSONEncoder()
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
        let encoder = JSONEncoder()
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

//        func getEvents() -> [Event] {
//            if let data = defaults.object(forKey: keys.events) as? Data {
//                if let event = try? decoder.decode([Event].self, from: data) {
//                    return event
//                }
//            }
//            return []
//        }
//
//        func getFavorites() -> Set<Event> {
//            if let data = defaults.object(forKey: keys.favorite) as? Data {
//                if let favorites = try? decoder.decode(Set<Event>.self, from: data) {
//                    return favorites
//                }
//            }
//            return Set<Event>()
//        }
//
//        let events = Observable.of(getEvents())
//        let favorite = Observable.of(getFavorites())

        let swapFavoriteMark = PublishSubject<Event>()
        swapFavoriteMark.subscribe(onNext: { event in
            var favoriteSet = Set<Event>()
            if let data = defaults.object(forKey: keys.favorite) as? Data {
                if var favoriteSet = try? decoder.decode(Set<Event>.self, from: data) {
                    if favoriteSet.contains(event) {
                        favoriteSet.remove(event)
                    } else {
                        favoriteSet.insert(event)
                    }
                }
            } else {
                favoriteSet.insert(event)
            }
            if let encoded = try? encoder.encode(favoriteSet) {
                defaults.set(encoded, forKey: keys.favorite)
            }
        }).disposed(by: disposeBag)

        let update = PublishSubject<[Event]>()
        update.subscribe(onNext: { events in
            if let encoded = try? encoder.encode(events) {
                defaults.set(encoded, forKey: keys.events)
            }
        }).disposed(by: disposeBag)

        input = Input(update: update, swapFavoriteMark: swapFavoriteMark)
//        output = Output(favorite: favorite, events: events)
    }
}
