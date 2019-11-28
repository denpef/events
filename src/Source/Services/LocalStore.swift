import Foundation

/// Local cache service
final class LocalStore {
    var favorite: Set<Event> {
        return defaults.object(forKey: "favorite") as? Set<Event> ?? Set<Event>()
    }

    var events: [Event] {
        return defaults.object(forKey: "events") as? [Event] ?? []
    }

    func swapFavoriteMark(of event: Event) {
        var favoriteSet = defaults.object(forKey: "favorite") as? Set<Event> ?? Set<Event>()
        if favoriteSet.contains(event) {
            favoriteSet.remove(event)
        } else {
            favoriteSet.insert(event)
        }
        defaults.set(favoriteSet, forKey: "favorite")
    }

    func update(events: [Event]) {
        defaults.set(events, forKey: "events")
    }

    private let defaults = UserDefaults.standard
}
