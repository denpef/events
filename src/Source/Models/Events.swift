import Foundation

/// Wrapper over Events API
///
struct EventList: Codable {
    let event: [Event]
}

/// Wrapper over Events API
///
struct EventsData: Codable {
    let events: EventList
}

/// Model of event data
///
struct Event: Codable {
    var id: String
    var title: String
    var start_time: String
    var url: String

    /// Date for display in format "E, dd MMM yyyy HH:mm"
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
