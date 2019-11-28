struct EventList: Decodable {
    let event: [Event]
}

struct EventsData: Decodable {
    let events: EventList
}

struct Event: Decodable {
    var id: String
    var title: String
    // swiftlint:disable identifier_name
    var start_time: String
    var url: String
}

extension Event: Hashable {}
