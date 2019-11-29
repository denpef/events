import Foundation

protocol Configurable {
    func configure(with serviceContainer: ServiceContainerType)
}

protocol ServiceContainerType {
    var localStorage: LocalStorage { get }
    var eventService: EventService { get }
}

final class ServiceContainer: ServiceContainerType {
    var localStorage: LocalStorage
    var eventService: EventService

    init(localStorage: LocalStorage, eventService: EventService) {
        self.localStorage = localStorage
        self.eventService = eventService
    }
}
