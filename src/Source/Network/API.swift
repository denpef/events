import RxCocoa
import RxSwift

/// Network Interface
///
final class API {
    // MARK: - Private properties

    private let networkProvider: NetworkProvider
    private let eventPath = "http://api.eventful.com/json/events/search?app_key=CKKnt488bNT6HK2c&keywords=books&location=San+Diego&date=Tomorrow&page_size=50"

    // MARK: - Init

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    // MARK: - Methods

    /// Executes a query and returns the result as Observable
    func getEvents() -> Observable<EventsData> {
        return networkProvider.request(url: eventPath)
    }
}
