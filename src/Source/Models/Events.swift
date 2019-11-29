struct EventList: Codable {
    let event: [Event]
}

struct EventsData: Codable {
    let events: EventList
}

struct Event: Codable {
    var id: String
    var title: String
    // swiftlint:disable identifier_name
    var start_time: String
    var url: String
}

extension Event: Hashable {}

extension Event: Comparable {
    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.title < rhs.title {
            return true
        } else if lhs.start_time < rhs.start_time {
            return true
        } else {
            return lhs.id < rhs.id
        }
    }
}
