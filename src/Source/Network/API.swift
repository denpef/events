import RxCocoa
import RxSwift

/// Network Interface
///
final class API {
    private let networkProvider: NetworkProvider
    private let eventPath = "http://api.eventful.com/json/events/search?app_key=CKKnt488bNT6HK2c&keywords=books&location=San+Diego&date=Future"

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    /// Executes a query and returns the result as Observable
    func getEvents() -> Observable<EventsData> {
        return networkProvider.request(url: eventPath)
    }
}
