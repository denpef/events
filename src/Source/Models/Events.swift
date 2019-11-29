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
