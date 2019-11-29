import Foundation

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

    var dateDescription: String {
        guard let date = DateFormatter.APIFormatter.date(from: self.start_time) else {
            return ""
        }
        return DateFormatter.DescriptionFormatter.string(from: date)
    }
}

extension Event: Hashable {}

extension Event: Comparable {
    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.title < rhs.title {
            return true
        } else {
            return lhs.id < rhs.id
        }
    }
}
