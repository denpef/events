import Foundation

/// Required for configuration viewModel
protocol Configurable {
    func configure(with serviceContainer: ServiceContainerType)
}

/// Used to store services
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
